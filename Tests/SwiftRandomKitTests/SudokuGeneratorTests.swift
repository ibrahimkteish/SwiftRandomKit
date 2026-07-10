import XCTest
import SwiftRandomKit
import SwiftRandomKitGenerators

final class SudokuGeneratorTests: XCTestCase {

    /// Asserts no row, column or 3x3 box contains a duplicate non-zero value.
    private func assertValidPuzzle(_ grid: [[Int]], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(grid.count, 9, "9 rows", file: file, line: line)
        for row in grid {
            XCTAssertEqual(row.count, 9, "9 columns", file: file, line: line)
        }

        for i in 0..<9 {
            var rowSeen = Set<Int>()
            var colSeen = Set<Int>()
            for j in 0..<9 {
                let rowValue = grid[i][j]
                let colValue = grid[j][i]
                XCTAssertTrue((0...9).contains(rowValue), file: file, line: line)
                if rowValue != 0 {
                    XCTAssertTrue(rowSeen.insert(rowValue).inserted, "Duplicate \(rowValue) in row \(i)", file: file, line: line)
                }
                if colValue != 0 {
                    XCTAssertTrue(colSeen.insert(colValue).inserted, "Duplicate \(colValue) in column \(i)", file: file, line: line)
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
                            XCTAssertTrue(boxSeen.insert(value).inserted, "Duplicate \(value) in box (\(boxRow),\(boxCol))", file: file, line: line)
                        }
                    }
                }
            }
        }
    }

    func testGeneratedPuzzlesAreValid() {
        var rng = LCRNG(seed: 1)
        let generator = SudokuGenerator(difficulty: .medium)

        for _ in 0..<3 {
            assertValidPuzzle(generator.run(using: &rng))
        }
    }

    func testClueCountsMatchDifficulty() {
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
            XCTAssertTrue(range.contains(clues), "\(difficulty) should leave \(range) clues, left \(clues)")
        }
    }

    func testDeterministicWithSameSeed() {
        var rng1 = LCRNG(seed: 7)
        var rng2 = LCRNG(seed: 7)
        let generator = SudokuGenerator(difficulty: .easy)

        XCTAssertEqual(generator.run(using: &rng1), generator.run(using: &rng2))
    }
}
