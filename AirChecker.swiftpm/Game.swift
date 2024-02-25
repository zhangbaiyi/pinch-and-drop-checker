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
    
    var board: [[Character]] =
    [
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
    var selectedKind: Character? = nil
    
    private init() {}
    
    func removeCheckerAt(row: Int, column: Int) {
        if board[row][column] != "." {
            board[row][column] = "."
        }
    }
    
    func getSelectedCheckerKind() -> Character{
        guard selected != nil else {
            return "n"
        }
        return board[selected!.row][selected!.col]
        
    }
    
    func returnChecker(kind: Character) {
        guard selected != nil else {
            return
        }
        guard selectedKind != nil else {
            return
        }
        board[selected!.row][selected!.col] = selectedKind!
    }
    
    func calculateDistance(from: Coordinate, to: Coordinate) -> Int {
        abs(to.row - from.row) + abs(to.col - from.col)
    }
    
    func placeCheckerAt(row: Int, column: Int) {
  
        guard Game.shared.selected != nil else {
            return
        }
        let start = Game.shared.selected
        let end = Coordinate(row: row, col: column)
        
        let captures = findWayToDestination(start: Game.shared.selected!, end: end)
        if !captures.isEmpty {
            for coordinate in captures {
                if board[coordinate.row][coordinate.col] == "#" {
                    board[coordinate.row][coordinate.col] = "."
                }
            }
        }
        if board[row][column] == "." {
            board[row][column] = "@"
        }
        Game.shared.selected = nil
        Game.shared.selectedKind = nil
        computerMove()
    }
    
    
    func isWhiteCheckerAt(row: Int, col: Int) -> Bool{
        guard row >= 0, row < board.count, col >= 0, col < board[row].count else {
            return false
        }
        return board[row][col] == "@"
    }
    
    func findWayToDestination(start: Coordinate, end: Coordinate) -> Set<Coordinate> {
        var res: Set<Coordinate> = []
        let directions = [(-1, -1), (-1, 1), (1, 1), (1, -1)]
        
        func findCaptures(from coordinate: Coordinate, visited: inout Set<Coordinate>, currentPath: inout Set<Coordinate>) -> Bool {
            if coordinate.row == end.row && coordinate.col == end.col {
                res = currentPath
                return true
            }
            
            for (dRow, dCol) in directions {
                let jumpRow = coordinate.row + 2*dRow
                let jumpCol = coordinate.col + 2*dCol
                
                if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count, !visited.contains(Coordinate(row: jumpRow, col: jumpCol)) {
                    if board[coordinate.row + dRow][coordinate.col + dCol] == "#" && board[jumpRow][jumpCol] == "." {
                        let newCoordinate = Coordinate(row: jumpRow, col: jumpCol)
                        visited.insert(newCoordinate)
                        let capturedCoordinate = Coordinate(row: coordinate.row + dRow, col: coordinate.col + dCol)
                        currentPath.insert(capturedCoordinate)
                        if findCaptures(from: newCoordinate, visited: &visited, currentPath: &currentPath) {
                            return true
                        }
                        currentPath.remove(capturedCoordinate) // Backtrack
                    }
                }
            }
            return false
        }
        
        var visited: Set<Coordinate> = [start]
        var currentPath: Set<Coordinate> = []
        _ = findCaptures(from: start, visited: &visited, currentPath: &currentPath)
        return res
    }
    
    
    func findPossibleMoveDestination() -> Set<Coordinate> {
        guard let selected = selected else {
            print("possibleDrop -> selected is nil!!!")
            return []
        }
        let r = selected.row
        let c = selected.col
        var places: Set<Coordinate> = []
        
        let simpleMoveDirections = [(-1, -1), (-1, 1)]
        
        func calculateTotalDistance(from start: Coordinate, to end: Coordinate, currentDistance: Int) -> Int {
            return currentDistance + abs(end.row - start.row) + abs(end.col - start.col)
        }
        
        var localPlaces: Set<Coordinate> = []
        var visited: Set<Coordinate> = [Coordinate(row: r, col: c)]
        
        func findAllJumps(from coordinate: Coordinate, visited: inout Set<Coordinate>, totalDistance: Int, furthestDistance: inout Int) -> Set<Coordinate> {
            print(localPlaces)
            print(visited)
            let directions = [(-1, -1), (-1, 1), (1, 1), (1, -1)]
            
            for (dRow, dCol) in directions {
                let jumpRow = coordinate.row + 2*dRow
                let jumpCol = coordinate.col + 2*dCol
                
                if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count, !visited.contains(Coordinate(row: jumpRow, col: jumpCol)) {
                    if board[coordinate.row + dRow][coordinate.col + dCol] == "#" && board[jumpRow][jumpCol] == "." {
                        let newCoordinate = Coordinate(row: jumpRow, col: jumpCol)
                        visited.insert(newCoordinate)
                        
                        let currentTotalDistance = calculateTotalDistance(from: coordinate, to: newCoordinate, currentDistance: totalDistance)
                        
                        if currentTotalDistance > furthestDistance {
                            furthestDistance = currentTotalDistance
                            localPlaces = [newCoordinate]
                        } else if currentTotalDistance == furthestDistance {
                            localPlaces.insert(newCoordinate)
                        }
                        
                        _ = findAllJumps(from: newCoordinate, visited: &visited, totalDistance: currentTotalDistance, furthestDistance: &furthestDistance)
                    }
                }
            }
            return localPlaces
        }
        var furthestDistance = 0
        places = findAllJumps(from: Coordinate(row: selected.row, col: selected.col), visited: &visited, totalDistance: 0, furthestDistance: &furthestDistance)
        
        if places.isEmpty {
            for (dRow, dCol) in simpleMoveDirections {
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
        let direction_normal = [(-1, -1), (-1, 1)]
        let direction_king = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
        
        
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
                    }
                }
            }
        }
        if jumpers.isEmpty {
            for i in 0..<board.count {
                for j in 0..<board[i].count {
                    if board[i][j] == "@" {
                        let currentCoordinate = Coordinate(row: i, col: j)
                        for direction in direction_normal {
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
        return jumpers.isEmpty ? movable : jumpers
    }
    

    func computerMove() {
        let movableCheckers = findMovableCheckersForBlack()
        var possibleMoves: [(from: Coordinate, to: Coordinate)] = []
        
        let randomSelect = movableCheckers.randomElement()
        guard randomSelect != nil else {
            return
        }
        print("selected black move")
        print(randomSelect)
        print("Possible destinations for random seleced")
        let possiblePlaces = findPossibleMoveDestinationForComp(pick: randomSelect!)
        let des = possiblePlaces.randomElement()
        print(des)
        guard des != nil else {
            return
        }
        let captures = findWayToDestinationForComp(start: randomSelect!, end: des!)
        print(captures)
        
        if !captures.isEmpty {
            for coordinate in captures {
                if board[coordinate.row][coordinate.col] == "@" {
                    board[coordinate.row][coordinate.col] = "."
                }
            }
        }
        
        board[randomSelect!.row][randomSelect!.col] = "."
        board[des!.row][des!.col] = "#"
    }
    
    private func findMovableCheckersForBlack() -> Set<Coordinate> {
        var movable: Set<Coordinate> = []
        var jumpers: Set<Coordinate> = []
        let directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)] // Directions for jumps and moves
        let direction_normal = [(1, -1), (1, 1)]
        let direction_king = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
        
        
        for i in 0..<board.count {
            for j in 0..<board[i].count {
                if board[i][j] == "#" {
                    let currentCoordinate = Coordinate(row: i, col: j)
                    for direction in directions {
                        let jumpRow = i + 2 * direction.0
                        let jumpCol = j + 2 * direction.1
                        let middleRow = i + direction.0
                        let middleCol = j + direction.1
                        if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count,
                           board[middleRow][middleCol] == "@", board[jumpRow][jumpCol] == "." {
                            jumpers.insert(currentCoordinate)
                        }
                    }
                }
            }
        }
        
        if jumpers.isEmpty {
            for i in 0..<board.count {
                for j in 0..<board[i].count {
                    if board[i][j] == "#" {
                        for direction in direction_normal {
                            let currentCoordinate = Coordinate(row: i, col: j)
                            let moveRow = i + 1 * direction.0
                            let moveCol = j + 1 * direction.1
                            if moveRow >= 0, moveRow < board.count, moveCol >= 0, moveCol < board[moveRow].count,
                               board[moveRow][moveCol] == "." {
                                movable.insert(currentCoordinate)
                            }
                        }
                    }
                }
            }
        }
        return jumpers.isEmpty ? movable : jumpers
    }

    private func findPossibleMoveDestinationForComp(pick: Coordinate) -> Set<Coordinate> {
        let r = pick.row
        let c = pick.col
        var places: Set<Coordinate> = []
        
        let simpleMoveDirections = [(1, -1), (1, 1)]
        
        func calculateTotalDistance(from start: Coordinate, to end: Coordinate, currentDistance: Int) -> Int {
            return currentDistance + abs(end.row - start.row) + abs(end.col - start.col)
        }
        
        var localPlaces: Set<Coordinate> = []
        var visited: Set<Coordinate> = [Coordinate(row: r, col: c)]
        
        func findAllJumps(from coordinate: Coordinate, visited: inout Set<Coordinate>, totalDistance: Int, furthestDistance: inout Int) -> Set<Coordinate> {
            print(localPlaces)
            print(visited)
            let directions = [(-1, -1), (-1, 1), (1, 1), (1, -1)]
            
            for (dRow, dCol) in directions {
                let jumpRow = coordinate.row + 2*dRow
                let jumpCol = coordinate.col + 2*dCol
                
                if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count, !visited.contains(Coordinate(row: jumpRow, col: jumpCol)) {
                    if board[coordinate.row + dRow][coordinate.col + dCol] == "@" && board[jumpRow][jumpCol] == "." {
                        let newCoordinate = Coordinate(row: jumpRow, col: jumpCol)
                        visited.insert(newCoordinate)
                        
                        let currentTotalDistance = calculateTotalDistance(from: coordinate, to: newCoordinate, currentDistance: totalDistance)
                        
                        if currentTotalDistance > furthestDistance {
                            furthestDistance = currentTotalDistance
                            localPlaces = [newCoordinate]
                        } else if currentTotalDistance == furthestDistance {
                            localPlaces.insert(newCoordinate)
                        }
                        
                        _ = findAllJumps(from: newCoordinate, visited: &visited, totalDistance: currentTotalDistance, furthestDistance: &furthestDistance)
                    }
                }
            }
            return localPlaces
        }
        var furthestDistance = 0
        places = findAllJumps(from: Coordinate(row: pick.row, col: pick.col), visited: &visited, totalDistance: 0, furthestDistance: &furthestDistance)
        
        if places.isEmpty {
            for (dRow, dCol) in simpleMoveDirections {
                let newRow = r + dRow
                let newCol = c + dCol
                if newRow >= 0, newRow < board.count, newCol >= 0, newCol < board[newRow].count, board[newRow][newCol] == "." {
                    places.insert(Coordinate(row: newRow, col: newCol))
                }
            }
        }
        
        return places
    }
    
    func findWayToDestinationForComp(start: Coordinate, end: Coordinate) -> Set<Coordinate> {
        var res: Set<Coordinate> = []
        let directions = [(-1, -1), (-1, 1), (1, 1), (1, -1)]
        
        func findCaptures(from coordinate: Coordinate, visited: inout Set<Coordinate>, currentPath: inout Set<Coordinate>) -> Bool {
            if coordinate.row == end.row && coordinate.col == end.col {
                res = currentPath
                return true
            }
            
            for (dRow, dCol) in directions {
                let jumpRow = coordinate.row + 2*dRow
                let jumpCol = coordinate.col + 2*dCol
                
                if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count, !visited.contains(Coordinate(row: jumpRow, col: jumpCol)) {
                    if board[coordinate.row + dRow][coordinate.col + dCol] == "@" && board[jumpRow][jumpCol] == "." {
                        let newCoordinate = Coordinate(row: jumpRow, col: jumpCol)
                        visited.insert(newCoordinate)
                        let capturedCoordinate = Coordinate(row: coordinate.row + dRow, col: coordinate.col + dCol)
                        currentPath.insert(capturedCoordinate)
                        if findCaptures(from: newCoordinate, visited: &visited, currentPath: &currentPath) {
                            return true
                        }
                        currentPath.remove(capturedCoordinate) // Backtrack
                    }
                }
            }
            return false
        }
        
        var visited: Set<Coordinate> = [start]
        var currentPath: Set<Coordinate> = []
        _ = findCaptures(from: start, visited: &visited, currentPath: &currentPath)
        return res
    }
    
    
    private func possibleDropPointForBlack(row: Int, col: Int, prioritizeCapture: Bool) -> Set<Coordinate> {
        var places: Set<Coordinate> = []
        let directions = [(1, -1), (1, 1), (-1, -1), (-1, 1)] // All directions for movement

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
