import Foundation
import SwiftRandomKit

/// A generator that produces valid Sudoku puzzles with configurable difficulty.
///
/// This generator creates a complete Sudoku solution and then removes numbers
/// based on the specified difficulty level to create a playable puzzle.
///
/// Example usage:
/// ```swift
/// // Create a generator for medium difficulty Sudoku puzzles
/// let sudokuGen = SudokuGenerator(difficulty: .medium)
/// 
/// // Generate a new puzzle
/// let puzzle = sudokuGen.run()
/// 
/// // Print the puzzle
/// for row in puzzle {
///     print(row.map { $0 == 0 ? "." : "\($0)" }.joined(separator: " "))
/// }
/// ```
public struct SudokuGenerator: RandomGenerator {
    public typealias Element = [[Int]]

    /// Difficulty levels for Sudoku puzzles, determining the number of initial clues.
    public enum Difficulty: Sendable {
        case easy      // 35-40 givens
        case medium    // 30-34 givens
        case hard      // 25-29 givens
        case expert    // 22-24 givens
        
        /// Returns a random generator for the number of clues appropriate for this difficulty level.
        fileprivate var cluesGenerator: some RandomGenerator<Int> {
            switch self {
            case .easy:   return IntGenerator(in: 35...40)
            case .medium: return IntGenerator(in: 30...34)
            case .hard:   return IntGenerator(in: 25...29)
            case .expert: return IntGenerator(in: 22...24)
            }
        }
    }

    private let difficulty: Difficulty
    
    /// Creates a new Sudoku puzzle generator with the specified difficulty.
    ///
    /// - Parameter difficulty: The difficulty level of the generated puzzles.
    public init(difficulty: Difficulty = .medium) {
        self.difficulty = difficulty
    }

    /// Generates a random Sudoku puzzle.
    ///
    /// - Parameter rng: The random number generator to use.
    /// - Returns: A 9x9 grid representing a Sudoku puzzle, with 0s indicating empty cells.
    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        // Generate a complete, valid Sudoku grid
        var grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        _ = fillGrid(&grid, using: &rng)

        // Remove numbers based on difficulty
        let clues = difficulty.cluesGenerator.run(using: &rng)
        removeNumbers(from: &grid, leaving: clues, using: &rng)

        return grid
    }

    private func fillGrid<RNG: RandomNumberGenerator>(_ grid: inout [[Int]], using rng: inout RNG) -> Bool {
        // Find the next empty cell
        for row in 0..<9 {
            for col in 0..<9 {
                if grid[row][col] == 0 {
                    // Try numbers 1-9 in random order. This runs inside the
                    // backtracking hot path, so shuffle in place rather than
                    // allocating a generator per cell visit.
                    var numbers = Array(1...9)
                    numbers.shuffle(using: &rng)
                    for number in numbers {
                        if isSafe(toPlace: number, at: (row, col), in: grid) {
                            grid[row][col] = number
                            if fillGrid(&grid, using: &rng) {
                                return true
                            }
                            grid[row][col] = 0
                        }
                    }
                    return false
                }
            }
        }
        return true
    }

    private func isSafe(toPlace number: Int, at position: (Int, Int), in grid: [[Int]]) -> Bool {
        let (row, col) = position

        // Check row and column
        for i in 0..<9 {
            if grid[row][i] == number || grid[i][col] == number {
                return false
            }
        }

        // Check 3x3 subgrid
        let startRow = row - row % 3
        let startCol = col - col % 3
        for r in 0..<3 {
            for c in 0..<3 {
                if grid[startRow + r][startCol + c] == number {
                    return false
                }
            }
        }
        return true
    }

    private func removeNumbers<RNG: RandomNumberGenerator>(from grid: inout [[Int]], leaving clues: Int, using rng: inout RNG) {
        // Create all possible positions
        var positions = [(Int, Int)]()
        for row in 0..<9 {
            for col in 0..<9 {
                positions.append((row, col))
            }
        }
        
        positions.shuffle(using: &rng)

        let cellsToRemove = 81 - clues
        for i in 0..<cellsToRemove {
            let (row, col) = positions[i]
            grid[row][col] = 0
        }
    }
}

// MARK: - Convenience Extensions

public extension RandomGenerators {
    /// Creates a generator for Sudoku puzzles with the specified difficulty.
    ///
    /// - Parameter difficulty: The difficulty level of the generated puzzles.
    /// - Returns: A generator that produces Sudoku puzzles.
    static func sudoku(difficulty: SudokuGenerator.Difficulty = .medium) -> SudokuGenerator {
        SudokuGenerator(difficulty: difficulty)
    }
}
