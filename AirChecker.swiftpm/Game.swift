//
//  Game.swift
//  AirChecker
//
//  Created by Baiyi Zhang on 2/24/24.
//

import Foundation

class Game {
    
    static let shared = Game()
    
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
    
    func possibleDropPoint(row: Int, col: Int) -> Set<Coordinate> {
        var places: Set<Coordinate> = []
        //if board[row][col] == "@"
        let directions = [(-1, -1), (-1, 1)] // Assuming '@' represents a white checker, moving up the board
        
        for (dRow, dCol) in directions {
            let jumpRow = row + 2*dRow
            let jumpCol = col + 2*dCol
            if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count {
                // Check if there is an opponent checker to jump over and the landing square is empty
                if board[row + dRow][col + dCol] == "#" && board[jumpRow][jumpCol] == "." {
                    places.insert(Coordinate(row: jumpRow, col: jumpCol))
                }
            }
        }
        
        if !places.isEmpty {
            return places
        }
        
        for (dRow, dCol) in directions {
            let newRow = row + dRow
            let newCol = col + dCol
            if newRow >= 0, newRow < board.count, newCol >= 0, newCol < board[newRow].count, board[newRow][newCol] == "." {
                places.insert(Coordinate(row: newRow, col: newCol))
            }
        }
        print(places)
        return places
    }
    
    func findMovableCheckers() -> Set<Coordinate> {
        var movable: Set<Coordinate> = []
        for i in 0..<board.count {
            for j in 0..<board[i].count {
                if board[i][j] == "@" {
                    // User's checker, check if it can move upwards
                    if i > 0 { // Ensure it's not on the top row
                        if j > 0 && board[i - 1][j - 1] == "." {
                            movable.insert(Coordinate(row: i, col: j))
                        }
                        if j < board[i].count - 1 && board[i - 1][j + 1] == "." {
                            movable.insert(Coordinate(row: i, col: j))
                        }
                    }
                }
            }
        }
        return movable
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
        var possibleMoves: [(from: Coordinate, to: Coordinate)] = []
                for row in 0..<board.count {
            for col in 0..<board[row].count where board[row][col] == "#" {
                let possibleDropPoints = possibleDropPointForBlack(row: row, col: col)
                for dropPoint in possibleDropPoints {
                    possibleMoves.append((from: Coordinate(row: row, col: col), to: dropPoint))
                }
            }
        }
        
        if let randomMove = possibleMoves.randomElement() {
            performMove(from: randomMove.from, to: randomMove.to)
        }
    }
    
    private func possibleDropPointForBlack(row: Int, col: Int) -> Set<Coordinate> {
        var places: Set<Coordinate> = []
        let directions = [(1, -1), (1, 1), (-1, -1), (-1, 1)] // All directions for movement
        
        for (dRow, dCol) in directions {
            let jumpRow = row + 2 * dRow
            let jumpCol = col + 2 * dCol
            if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count {
                if board[row + dRow][col + dCol] == "@" && board[jumpRow][jumpCol] == "." {
                    places.insert(Coordinate(row: jumpRow, col: jumpCol))
                }
            }
        }
        
        if places.isEmpty {
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
