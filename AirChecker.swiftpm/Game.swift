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
        [".", "#", ".", "#", ".", "W", ".", "#"],
        [".", ".", "#", ".", ".", ".", ".", "."],
        [".", "B", ".", ".", ".", ".", ".", "."],
        ["B", ".", "B", ".", "B", ".", "B", "."],
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
        guard Game.shared.selectedKind != nil else {
            return
        }
        let start = Game.shared.selected
        let end = Coordinate(row: row, col: column)
        
        let captures = findWayToDestination(start: Game.shared.selected!, end: end)
        if !captures.isEmpty {
            for coordinate in captures {
                if isComputer(row: coordinate.row, col: coordinate.col) {
                    board[coordinate.row][coordinate.col] = "."
                }
            }
        }
        if row == 0 && selectedKind! == "@" && board[row][column] == "." {
            board[row][column] = "W"
            print(board)
        }
        else if board[row][column] == "."{
            board[row][column] = selectedKind!
        }
        Game.shared.selected = nil
        Game.shared.selectedKind = nil
        computerMove()
    }
    
    func isUser(row: Int, col: Int) -> Bool{
        if board[row][col] == "@" || board[row][col] == "W" {
            return true
        }
        else {
            return false
        }
    }
    
    func isComputer(row: Int, col: Int) -> Bool{
        if board[row][col] == "#" || board[row][col] == "B" {
            return true
        }
        else {
            return false
        }
    }
    
    func isWhiteCheckerAt(row: Int, col: Int) -> Bool{
        guard row >= 0, row < board.count, col >= 0, col < board[row].count else {
            return false
        }
        return isUser(row: row, col: col)
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
                    if isComputer(row: coordinate.row + dRow, col: coordinate.col + dCol) && board[jumpRow][jumpCol] == "." {
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
        guard let usersPick = selected else {
            return []
        }
        guard selectedKind != nil else {
            return []
        }
        let r = usersPick.row
        let c = usersPick.col
        print("111 ", r, c, board[r][c])
        var places: Set<Coordinate> = []
        
        let simpleMoveDirections = [(-1, -1), (-1, 1)]
        let kingMoveDirections = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
        
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
                    if isComputer(row: coordinate.row + dRow, col: coordinate.col + dCol) && board[jumpRow][jumpCol] == "." {
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
        places = findAllJumps(from: Coordinate(row: usersPick.row, col: usersPick.col), visited: &visited, totalDistance: 0, furthestDistance: &furthestDistance)
        
        if places.isEmpty {
            if selectedKind! == "@" {
                for (dRow, dCol) in simpleMoveDirections {
                    let newRow = r + dRow
                    let newCol = c + dCol
                    if newRow >= 0, newRow < board.count, newCol >= 0, newCol < board[newRow].count, board[newRow][newCol] == "." {
                        places.insert(Coordinate(row: newRow, col: newCol))
                    }
                }
            }
            if selectedKind! == "W" {
                for (dRow, dCol) in kingMoveDirections{
                    let newRow = r + dRow
                    let newCol = c + dCol
                    if newRow >= 0, newRow < board.count, newCol >= 0, newCol < board[newRow].count, board[newRow][newCol] == "." {
                        places.insert(Coordinate(row: newRow, col: newCol))
                    }
                }
            }
        }
        
        return places
    }
    
    
    func findMovableCheckers() -> Set<Coordinate> {
        var movable: Set<Coordinate> = []
        var jumpers: Set<Coordinate> = []
        let directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
        let direction_normal = [(-1, -1), (-1, 1)]
        
        
        for i in 0..<board.count {
            for j in 0..<board[i].count {
                if isUser(row: i, col: j) {
                    let currentCoordinate = Coordinate(row: i, col: j)
                    for direction in directions {
                        let jumpRow = i + 2 * direction.0
                        let jumpCol = j + 2 * direction.1
                        let middleRow = i + direction.0
                        let middleCol = j + direction.1
                        
                        if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count, isComputer(row: middleRow, col: middleCol), board[jumpRow][jumpCol] == "." {
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
                    if board[i][j] == "W" {
                        let currentCoordinate = Coordinate(row: i, col: j)
                        for direction in directions {
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
        let movableCheckers = findMovableCheckersForComputer()
        let randomSelect = movableCheckers.randomElement()
        guard randomSelect != nil else {
            return
        }
        let possiblePlaces = findPossibleMoveDestinationForComputer(pick: randomSelect!)
        let des = possiblePlaces.randomElement()
        guard des != nil else {
            return
        }
        let captures = findWayToDestinationForComputer(start: randomSelect!, end: des!)
        print(captures)
        
        if !captures.isEmpty {
            for coordinate in captures {
                if isUser(row: coordinate.row, col: coordinate.col) {
                    board[coordinate.row][coordinate.col] = "."
                }
            }
        }
        
        let selectedKindToMove = board[randomSelect!.row][randomSelect!.col]
        board[randomSelect!.row][randomSelect!.col] = "."
        if des!.row == 7 && selectedKindToMove == "#"{
            board[des!.row][des!.col] = "B"

        }
        else {
            board[des!.row][des!.col] = selectedKindToMove
        }
    }
    
    private func findMovableCheckersForComputer() -> Set<Coordinate> {
        var movable: Set<Coordinate> = []
        var jumpers: Set<Coordinate> = []
        let directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)] // Directions for jumps and moves
        let direction_normal = [(1, -1), (1, 1)]
        
        
        for i in 0..<board.count {
            for j in 0..<board[i].count {
                if isComputer(row: i, col: j) {
                    let currentCoordinate = Coordinate(row: i, col: j)
                    for direction in directions {
                        let jumpRow = i + 2 * direction.0
                        let jumpCol = j + 2 * direction.1
                        let middleRow = i + direction.0
                        let middleCol = j + direction.1
                        if jumpRow >= 0, jumpRow < board.count, jumpCol >= 0, jumpCol < board[jumpRow].count, isUser(row: middleRow, col: middleCol), board[jumpRow][jumpCol] == "." {
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
                    if board[i][j] == "B" {
                        for direction in directions {
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

    private func findPossibleMoveDestinationForComputer(pick: Coordinate) -> Set<Coordinate> {
        let r = pick.row
        let c = pick.col
        var places: Set<Coordinate> = []
        
        let simpleMoveDirections = [(1, -1), (1, 1)]
        let KingMoveDirections = [(1, -1), (1, 1), (-1, -1), (-1, 1)]
        
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
                    if isUser(row: coordinate.row + dRow, col: coordinate.col + dCol) && board[jumpRow][jumpCol] == "." {
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
            if board[r][c] == "#" {
                for (dRow, dCol) in simpleMoveDirections {
                    let newRow = r + dRow
                    let newCol = c + dCol
                    if newRow >= 0, newRow < board.count, newCol >= 0, newCol < board[newRow].count, board[newRow][newCol] == "." {
                        places.insert(Coordinate(row: newRow, col: newCol))
                    }
                }
            }
            if board[r][c] == "B" {
                for (dRow, dCol) in KingMoveDirections {
                    let newRow = r + dRow
                    let newCol = c + dCol
                    if newRow >= 0, newRow < board.count, newCol >= 0, newCol < board[newRow].count, board[newRow][newCol] == "." {
                        places.insert(Coordinate(row: newRow, col: newCol))
                    }
                }
            }
        }
        
        return places
    }
    
    func findWayToDestinationForComputer(start: Coordinate, end: Coordinate) -> Set<Coordinate> {
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
                    if isUser(row: coordinate.row + dRow, col: coordinate.col + dCol) && board[jumpRow][jumpCol] == "." {
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
    
}
