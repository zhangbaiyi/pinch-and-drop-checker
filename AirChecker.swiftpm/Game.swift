//
//  Game.swift
//  AirChecker
//
//  Created by Baiyi Zhang on 2/24/24.
//

import Foundation

class Game {
    var board: [[Character]]
    
    init(board: [[Character]]) {
        self.board = board
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
        
        return (userMovableCheckers, compMovableCheckers)
    }
}

// Example usage:
let board: [[Character]] = [
    [".", "#", ".", "#", ".", "#", ".", "#"],
    ["#", ".", "#", ".", "#", ".", "#", "."],
    [".", "#", ".", "#", ".", "#", ".", "#"],
    [".", ".", ".", ".", ".", ".", ".", "."],
    [".", ".", ".", ".", ".", ".", ".", "."],
    ["@", ".", "@", ".", "@", ".", "@", "."],
    [".", "@", ".", "@", ".", "@", ".", "@"],
    ["@", ".", "@", ".", "@", ".", "@", "."]
]

let game = Game(board: board)
let movableCheckers = game.findMovableCheckers()
print("User Movable Checkers: \(movableCheckers.userMovableCheckers)")
print("Computer Movable Checkers: \(movableCheckers.compMovableCheckers)")
