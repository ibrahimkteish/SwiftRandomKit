import Foundation

public struct SudokuGenerator: RandomGenerator {
    public typealias Element = [[Int]]

    public enum Difficulty {
        case easy      // 35-40 givens
        case medium    // 30-34 givens
        case hard      // 25-29 givens
        case expert    // 22-24 givens
    }

    private let difficulty: Difficulty
    private let numberGenerator = IntGenerator(in: 1...9)
    private let positionGenerator = IntGenerator(in: 0..<9)

    public init(difficulty: Difficulty = .medium) {
        self.difficulty = difficulty
    }

    public func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element {
        // Generate a complete, valid Sudoku grid
        var grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        _ = fillGrid(&grid, using: &rng)

        // Remove numbers based on difficulty
        let clues = numberOfClues(for: difficulty, using: &rng)
        removeNumbers(from: &grid, leaving: clues, using: &rng)

        // Convert zeros to nils for optional representation
        let optionalGrid = grid
        return optionalGrid
    }

    private func fillGrid<RNG: RandomNumberGenerator>(_ grid: inout [[Int]], using rng: inout RNG) -> Bool {
        // Find the next empty cell
        for row in 0..<9 {
            for col in 0..<9 {
                if grid[row][col] == 0 {
                    // Try numbers 1-9 in random order
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

    private func numberOfClues<RNG: RandomNumberGenerator>(for difficulty: Difficulty, using rng: inout RNG) -> Int {
        switch difficulty {
        case .easy:   return IntGenerator(in: 35...40).run(using: &rng)
        case .medium: return IntGenerator(in: 30...34).run(using: &rng)
        case .hard:   return IntGenerator(in: 25...29).run(using: &rng)
        case .expert: return IntGenerator(in: 22...24).run(using: &rng)
        }
    }
}
