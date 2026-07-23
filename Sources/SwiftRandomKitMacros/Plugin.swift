import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftRandomKitMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RandomGenerableMacro.self,
        GenMacro.self
    ]
}
