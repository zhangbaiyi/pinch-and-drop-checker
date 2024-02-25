//
//  Game.swift
//  AirChecker
//
//  Created by Baiyi Zhang on 2/24/24.
//

import Foundation

class Game {
    
    static let shared = Game()
    
    var state: GameState = .choice
    
    var board: [[Character]] = [
        [".", "#", ".", "#", ".", "#", ".", "#"],
        ["#", ".", "#", ".", "#", ".", "#", "."],
        [".", "#", ".", "#", ".", "#", ".", "#"],
        [".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", "."],
        ["@", ".", "@", ".", "@", ".", "@", "."],
        [".", "@", ".", "@", ".", "@", ".", "@"],
        ["@", ".", "@", ".", "@", ".", "@", "."]
    ]
    
    var selected: Coordinate? = nil
    
    private init() {}
    
    func removeCheckerAt(row: Int, column: Int) {
        if board[row][column] != "." {
            board[row][column] = "."
        }
    }
    
    func placeCheckerAt(row: Int, column: Int) {
        if board[row][column] == "." {
            board[row][column] = "@"
        }
    }
    
    func isWhiteCheckerAt(row: Int, col: Int) -> Bool{
        guard row >= 0, row < board.count, col >= 0, col < board[row].count else {
            return false
        }
        return board[row][col] == "@"
    }
    
    func possibleDropPoint() -> Set<Coordinate> {
        guard selected != nil else {
            print("possibleDrop -> selected is nil!!!")
            return []
        }
        let r = selected!.row
        let c = selected!.col
        var places: Set<Coordinate> = []
        //if board[row][col] == "@"
        let directions = [(-1, -1), (-1, 1)] // Assuming '@' represents a white checker, moving up the board
        
        for (dRow, dCol) in directions {
            let jumpRow = r + 2*dRow
            let jumpCol = c + 2*dCol
            if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count {
                // Check if there is an opponent checker to jump over and the landing square is empty
                if board[r + dRow][c + dCol] == "#" && board[jumpRow][jumpCol] == "." {
                    places.insert(Coordinate(row: jumpRow, col: jumpCol))
                }
            }
        }
        
        if places.isEmpty {
            for (dRow, dCol) in directions {
                let newRow = r + dRow
                let newCol = c + dCol
                if newRow >= 0, newRow < board.count, newCol >= 0, newCol < board[newRow].count, board[newRow][newCol] == "." {
                    places.insert(Coordinate(row: newRow, col: newCol))
                }
            }
        }
        return places
    }
    
    func findMovableCheckers() -> Set<Coordinate> {
        var movable: Set<Coordinate> = []
        var jumpers: Set<Coordinate> = []
        let directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)] // Directions for jumps and moves
        
        for i in 0..<board.count {
            for j in 0..<board[i].count {
                if board[i][j] == "@" {
                    let currentCoordinate = Coordinate(row: i, col: j)
                    for direction in directions {
                        let jumpRow = i + 2 * direction.0
                        let jumpCol = j + 2 * direction.1
                        let middleRow = i + direction.0
                        let middleCol = j + direction.1
                        
                        // Check for possible jumps
                        if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count,
                           board[middleRow][middleCol] == "#", board[jumpRow][jumpCol] == "." {
                            jumpers.insert(currentCoordinate)
                        }
                        
                        // Check for simple moves if no jumpers found yet
                        if jumpers.isEmpty {
                            let moveRow = i + direction.0
                            let moveCol = j + direction.1
                            if moveRow >= 0, moveRow < board.count, moveCol >= 0, moveCol < board[moveRow].count,
                               board[moveRow][moveCol] == "." {
                                movable.insert(currentCoordinate)
                            }
                        }
                    }
                }
            }
        }
        
        // Priority to jumpers if available
        return jumpers.isEmpty ? movable : jumpers
    }
    
    func placedChecker(from: Coordinate, to: Coordinate) {
        //todo: update chessboard
        //1. eat black checkers if any
        //2. call function blackCheckerMove()
        let isJump = abs(from.row - to.row) == 2 && abs(from.col - to.col) == 2
        if isJump {
            let middleRow = (from.row + to.row) / 2
            let middleCol = (from.col + to.col) / 2
            if board[middleRow][middleCol] == "#" {
                board[middleRow][middleCol] = "."
            }
        }
        computerMove()
    }
    
    func computerMove() {
        let movableCheckers = findMovableCheckersForBlack()
        var possibleMoves: [(from: Coordinate, to: Coordinate)] = []

        // Prioritize captures
        for checker in movableCheckers {
            let possibleDropPoints = possibleDropPointForBlack(row: checker.row, col: checker.col, prioritizeCapture: true)
            for dropPoint in possibleDropPoints {
                possibleMoves.append((from: checker, to: dropPoint))
            }
        }

        // If no captures, add simple moves
        if possibleMoves.isEmpty {
            for checker in movableCheckers {
                let possibleDropPoints = possibleDropPointForBlack(row: checker.row, col: checker.col, prioritizeCapture: false)
                for dropPoint in possibleDropPoints {
                    possibleMoves.append((from: checker, to: dropPoint))
                }
            }
        }

        // Randomly choose a move from the list of possible moves
        if let randomMove = possibleMoves.randomElement() {
            performMove(from: randomMove.from, to: randomMove.to)
        }
    }

    private func findMovableCheckersForBlack() -> Set<Coordinate> {
        var movable: Set<Coordinate> = []
        for row in 0..<board.count {
            for col in 0..<board[row].count where board[row][col] == "#" {
                if !possibleDropPointForBlack(row: row, col: col, prioritizeCapture: true).isEmpty || !possibleDropPointForBlack(row: row, col: col, prioritizeCapture: false).isEmpty {
                    movable.insert(Coordinate(row: row, col: col))
                }
            }
        }
        return movable
    }

    private func possibleDropPointForBlack(row: Int, col: Int, prioritizeCapture: Bool) -> Set<Coordinate> {
        var places: Set<Coordinate> = []
        let directions = [(1, -1), (1, 1), (-1, -1), (-1, 1)] // All directions for movement

        // First check for jumps if prioritizing captures
        if prioritizeCapture {
            for (dRow, dCol) in directions {
                let jumpRow = row + 2 * dRow
                let jumpCol = col + 2 * dCol
                if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count {
                    if board[row + dRow][col + dCol] == "@" && board[jumpRow][jumpCol] == "." {
                        places.insert(Coordinate(row: jumpRow, col: jumpCol))
                    }
                }
            }
        }

        // If not prioritizing captures or no jumps available, check for simple moves
        if places.isEmpty || !prioritizeCapture {
            for (dRow, dCol) in directions {
                let newRow = row + dRow
                let newCol = col + dCol
                if newRow >= 0, newRow < board.count, newCol >= 0, newCol < board[newRow].count, board[newRow][newCol] == "." {
                    places.insert(Coordinate(row: newRow, col: newCol))
                }
            }
        }

        return places
    }
    
    private func performMove(from: Coordinate, to: Coordinate) {
        // Remove the checker from the original position
        board[from.row][from.col] = "."
        // Place the checker in the new position
        board[to.row][to.col] = "#"
        // If the move was a jump, remove the jumped checker
        let isJump = abs(from.row - to.row) == 2 && abs(from.col - to.col) == 2
        if isJump {
            let middleRow = (from.row + to.row) / 2
            let middleCol = (from.col + to.col) / 2
            board[middleRow][middleCol] = "."
        }
    }
    
}
