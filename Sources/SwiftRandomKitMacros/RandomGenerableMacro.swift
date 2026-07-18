import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implements the `@RandomGenerable` extension macro.
///
/// For a struct, synthesizes a `RandomGenerable` conformance whose `generator` builds
/// the type through its memberwise initializer, generating each stored property with
/// either its `@Gen(...)` override or the property type's default `generator`.
///
/// For an enum, synthesizes a conformance whose `generator` picks a case uniformly at
/// random and generates any associated values the same way.
public struct RandomGenerableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // The compiler passes an empty protocol list when the conformance is already
        // declared (and test harnesses pass none at all). Still synthesize the
        // generator; just leave the conformance clause off the extension.
        let inheritance = protocols.isEmpty ? "" : ": SwiftRandomKit.RandomGenerable"

        let typeName = type.trimmed.description
        let access = accessPrefix(for: declaration)

        let runBody: String
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            try rejectGenerics(structDecl.genericParameterClause, attribute: node)
            runBody = try structRunBody(structDecl, typeName: typeName)
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            try rejectGenerics(enumDecl.genericParameterClause, attribute: node)
            runBody = try enumRunBody(enumDecl, typeName: typeName, attribute: node)
        } else {
            throw error(.notAStructOrEnum, at: node)
        }

        let extensionDecl: DeclSyntax = """
            extension \(raw: typeName)\(raw: inheritance) {
                \(raw: access)static var generator: SwiftRandomKit.AnyRandomGenerator<\(raw: typeName)> {
                    SwiftRandomKit.AnyRandomGenerator<\(raw: typeName)> { rng in
            \(raw: runBody)
                    }
                }
            }
            """
        return [extensionDecl.cast(ExtensionDeclSyntax.self)]
    }

    // MARK: Structs

    private static func structRunBody(
        _ structDecl: StructDeclSyntax,
        typeName: String
    ) throws -> String {
        let properties = try storedProperties(of: structDecl)
        guard !properties.isEmpty else {
            return "            \(typeName)()"
        }
        var lines = ["            \(typeName)("]
        for (index, property) in properties.enumerated() {
            let comma = index == properties.count - 1 ? "" : ","
            lines.append("                \(property.name): \(property.generator).run(using: &rng)\(comma)")
        }
        lines.append("            )")
        return lines.joined(separator: "\n")
    }

    private struct StoredProperty {
        var name: String
        /// Source text of the expression that produces this property's generator.
        var generator: String
    }

    private static func storedProperties(of structDecl: StructDeclSyntax) throws -> [StoredProperty] {
        var properties: [StoredProperty] = []
        for member in structDecl.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self) else { continue }
            let modifiers = variable.modifiers.map(\.name.tokenKind)
            if modifiers.contains(.keyword(.static)) || modifiers.contains(.keyword(.class))
                || modifiers.contains(.keyword(.lazy)) {
                continue
            }

            let genOverride = genAttribute(on: variable)
            if genOverride != nil && variable.bindings.count > 1 {
                throw error(.genOnMultipleBindings, at: variable)
            }

            let isLet = variable.bindingSpecifier.tokenKind == .keyword(.let)
            let bindings = Array(variable.bindings)
            for (index, binding) in bindings.enumerated() {
                // Computed properties have accessors; observers (willSet/didSet) are stored.
                if let accessorBlock = binding.accessorBlock {
                    guard case .accessors(let accessors) = accessorBlock.accessors,
                        accessors.allSatisfy({
                            $0.accessorSpecifier.tokenKind == .keyword(.willSet)
                                || $0.accessorSpecifier.tokenKind == .keyword(.didSet)
                        })
                    else { continue }
                }
                // A `let` with a default value is not part of the memberwise initializer.
                if isLet && binding.initializer != nil { continue }

                guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                    throw error(.unsupportedPattern, at: binding)
                }
                let name = pattern.identifier.text

                if let genOverride {
                    properties.append(StoredProperty(name: name, generator: "(\(genOverride))"))
                    continue
                }

                guard let type = resolvedType(for: binding, at: index, in: bindings) else {
                    throw error(.missingTypeAnnotation, at: binding)
                }
                properties.append(StoredProperty(name: name, generator: "\(typeExpression(type)).generator"))
            }
        }
        return properties
    }

    /// The type of a binding, honoring the `var a, b: Int` form where a trailing
    /// annotation covers the preceding un-annotated, un-initialized bindings.
    private static func resolvedType(
        for binding: PatternBindingSyntax,
        at index: Int,
        in bindings: [PatternBindingSyntax]
    ) -> TypeSyntax? {
        if let annotation = binding.typeAnnotation {
            return annotation.type
        }
        guard binding.initializer == nil else { return nil }
        for later in bindings[(index + 1)...] {
            if later.initializer != nil { return nil }
            if let annotation = later.typeAnnotation { return annotation.type }
        }
        return nil
    }

    // MARK: Enums

    private static func enumRunBody(
        _ enumDecl: EnumDeclSyntax,
        typeName: String,
        attribute node: AttributeSyntax
    ) throws -> String {
        let cases = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap(\.elements)
        guard !cases.isEmpty else {
            throw error(.enumWithoutCases, at: node)
        }

        if cases.count == 1 {
            return "            return \(caseExpression(cases[0], typeName: typeName))"
        }

        var lines = ["            switch Swift.Int.random(in: 0...\(cases.count - 1), using: &rng) {"]
        for (index, element) in cases.enumerated() {
            let label = index == cases.count - 1 ? "default" : "case \(index)"
            lines.append("            \(label):")
            lines.append("                return \(caseExpression(element, typeName: typeName))")
        }
        lines.append("            }")
        return lines.joined(separator: "\n")
    }

    private static func caseExpression(_ element: EnumCaseElementSyntax, typeName: String) -> String {
        let caseName = "\(typeName).\(element.name.text)"
        guard let parameters = element.parameterClause?.parameters, !parameters.isEmpty else {
            return caseName
        }
        let arguments = parameters.map { parameter -> String in
            let value = "\(typeExpression(parameter.type)).generator.run(using: &rng)"
            if let label = parameter.firstName, label.tokenKind != .wildcard {
                return "\(label.text): \(value)"
            }
            return value
        }
        return "\(caseName)(\(arguments.joined(separator: ", ")))"
    }

    // MARK: Shared helpers

    /// Spells a type as an expression a `.generator` access can hang off of.
    /// `String?` does not parse in expression position, so optional sugar is rewritten
    /// to `Swift.Optional<String>`.
    private static func typeExpression(_ type: TypeSyntax) -> String {
        if let optional = type.as(OptionalTypeSyntax.self) {
            return "Swift.Optional<\(optional.wrappedType.trimmed)>"
        }
        if let unwrapped = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return "Swift.Optional<\(unwrapped.wrappedType.trimmed)>"
        }
        return type.trimmed.description
    }

    private static func genAttribute(on variable: VariableDeclSyntax) -> String? {
        for attribute in variable.attributes {
            guard let attribute = attribute.as(AttributeSyntax.self) else { continue }
            let name = attribute.attributeName.trimmed.description
            guard name == "Gen" || name == "SwiftRandomKit.Gen" else { continue }
            guard case .argumentList(let arguments) = attribute.arguments,
                let first = arguments.first
            else { continue }
            return first.expression.trimmed.description
        }
        return nil
    }

    private static func accessPrefix(for declaration: some DeclGroupSyntax) -> String {
        for modifier in declaration.modifiers {
            switch modifier.name.tokenKind {
            case .keyword(.public), .keyword(.open):
                return "public "
            case .keyword(.package):
                return "package "
            default:
                continue
            }
        }
        return ""
    }

    private static func rejectGenerics(
        _ clause: GenericParameterClauseSyntax?,
        attribute: AttributeSyntax
    ) throws {
        if clause != nil {
            throw error(.genericType, at: attribute)
        }
    }

    private static func error(
        _ message: RandomGenerableDiagnostic,
        at node: some SyntaxProtocol
    ) -> DiagnosticsError {
        DiagnosticsError(diagnostics: [Diagnostic(node: Syntax(node), message: message)])
    }
}

/// Implements the `@Gen` marker macro. It expands to nothing: `@RandomGenerable` reads
/// the attribute's argument syntax directly off the property it decorates.
public struct GenMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(VariableDeclSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(node), message: RandomGenerableDiagnostic.genNotOnProperty)
            ])
        }
        return []
    }
}

enum RandomGenerableDiagnostic: String, DiagnosticMessage {
    case notAStructOrEnum
    case genericType
    case missingTypeAnnotation
    case unsupportedPattern
    case genOnMultipleBindings
    case genNotOnProperty
    case enumWithoutCases

    var message: String {
        switch self {
        case .notAStructOrEnum:
            return "@RandomGenerable can only be applied to a struct or an enum"
        case .genericType:
            return "@RandomGenerable does not support generic types"
        case .missingTypeAnnotation:
            return "@RandomGenerable requires an explicit type annotation for this property, or a @Gen override"
        case .unsupportedPattern:
            return "@RandomGenerable does not support tuple or pattern bindings"
        case .genOnMultipleBindings:
            return "@Gen cannot be applied to a declaration with multiple bindings; declare each property separately"
        case .genNotOnProperty:
            return "@Gen can only be applied to a stored property"
        case .enumWithoutCases:
            return "@RandomGenerable cannot derive a generator for an enum with no cases"
        }
    }

    var severity: DiagnosticSeverity { .error }

    var diagnosticID: MessageID {
        MessageID(domain: "SwiftRandomKitMacros", id: rawValue)
    }
}
