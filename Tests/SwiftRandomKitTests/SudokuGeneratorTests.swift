import Testing
import SwiftRandomKit
import SwiftRandomKitGenerators

struct SudokuGeneratorTests {

    /// Asserts no row, column or 3x3 box contains a duplicate non-zero value.
    private func assertValidPuzzle(_ grid: [[Int]], sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(grid.count == 9, "9 rows", sourceLocation: sourceLocation)
        for row in grid {
            #expect(row.count == 9, "9 columns", sourceLocation: sourceLocation)
        }

        for i in 0..<9 {
            var rowSeen = Set<Int>()
            var colSeen = Set<Int>()
            for j in 0..<9 {
                let rowValue = grid[i][j]
                let colValue = grid[j][i]
                #expect((0...9).contains(rowValue), sourceLocation: sourceLocation)
                if rowValue != 0 {
                    #expect(rowSeen.insert(rowValue).inserted, "Duplicate \(rowValue) in row \(i)", sourceLocation: sourceLocation)
                }
                if colValue != 0 {
                    #expect(colSeen.insert(colValue).inserted, "Duplicate \(colValue) in column \(i)", sourceLocation: sourceLocation)
                }
            }
        }

        for boxRow in stride(from: 0, to: 9, by: 3) {
            for boxCol in stride(from: 0, to: 9, by: 3) {
                var boxSeen = Set<Int>()
                for r in boxRow..<(boxRow + 3) {
                    for c in boxCol..<(boxCol + 3) {
                        let value = grid[r][c]
                        if value != 0 {
                            #expect(boxSeen.insert(value).inserted, "Duplicate \(value) in box (\(boxRow),\(boxCol))", sourceLocation: sourceLocation)
                        }
                    }
                }
            }
        }
    }

    @Test func generatedPuzzlesAreValid() {
        var rng = LCRNG(seed: 1)
        let generator = SudokuGenerator(difficulty: .medium)

        for _ in 0..<3 {
            assertValidPuzzle(generator.run(using: &rng))
        }
    }

    @Test func clueCountsMatchDifficulty() {
        var rng = LCRNG(seed: 42)
        let expectations: [(SudokuGenerator.Difficulty, ClosedRange<Int>)] = [
            (.easy, 35...40),
            (.medium, 30...34),
            (.hard, 25...29),
            (.expert, 22...24)
        ]

        for (difficulty, range) in expectations {
            let puzzle = SudokuGenerator(difficulty: difficulty).run(using: &rng)
            let clues = puzzle.flatMap { $0 }.filter { $0 != 0 }.count
            #expect(range.contains(clues), "\(difficulty) should leave \(range) clues, left \(clues)")
        }
    }

    @Test func deterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 7)
        var rng2 = LCRNG(seed: 7)
        let generator = SudokuGenerator(difficulty: .easy)

        #expect(generator.run(using: &rng1) == generator.run(using: &rng2))
    }
}
