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
    
    func findMovableCheckers() -> (userMovableCheckers: [[Int]], compMovableCheckers: [[Int]]) {
        var userMovableCheckers: [[Int]] = []
        var compMovableCheckers: [[Int]] = []
        
        for i in 0..<board.count {
            for j in 0..<board[i].count {
                if board[i][j] == "@" {
                    // User's checker, check if it can move upwards
                    if i > 0 { // Ensure it's not on the top row
                        if j > 0 && board[i - 1][j - 1] == "." {
                            userMovableCheckers.append([i, j])
                        }
                        if j < board[i].count - 1 && board[i - 1][j + 1] == "." {
                            userMovableCheckers.append([i, j])
                        }
                    }
                } else if board[i][j] == "#" {
                    // Computer's checker, check if it can move downwards
                    if i < board.count - 1 { // Ensure it's not on the bottom row
                        if j > 0 && board[i + 1][j - 1] == "." {
                            compMovableCheckers.append([i, j])
                        }
                        if j < board[i].count - 1 && board[i + 1][j + 1] == "." {
                            compMovableCheckers.append([i, j])
                        }
                    }
                }
            }
        }
        print(userMovableCheckers)
        
        return (userMovableCheckers, compMovableCheckers)
    }
}
