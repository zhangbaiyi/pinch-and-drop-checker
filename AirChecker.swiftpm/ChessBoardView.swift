import UIKit

class ChessBoardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBoard()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBoard()
    }
    
    private func setupBoard() {
        let squareSize = self.bounds.width / 8
        for row in 0..<8 {
            for column in 0..<8 {
                let square = UIView(frame: CGRect(x: CGFloat(column) * squareSize, y: CGFloat(row) * squareSize, width: squareSize, height: squareSize))
                if (row + column) % 2 == 0 {
                    square.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                } else {
                    square.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                }
                self.addSubview(square)
            }
        }
    }
    
    func addChecker(at row: Int, column: Int, color: Checker.Color) {
        let squareSize = self.bounds.width / 8
        let checkerSize = squareSize * 0.8 // Checkers are slightly smaller than the squares
        let xOffset = (squareSize - checkerSize) / 2
        let yOffset = (squareSize - checkerSize) / 2
        let checker = Checker(color: color, location: CGPoint(x: CGFloat(column) * squareSize + xOffset, y: CGFloat(row) * squareSize + yOffset), size: checkerSize)
        checker.tag = row * 8 + column
        self.addSubview(checker)
    }
    
    func removeGlowingCircleHintsFromView() {
        self.subviews.forEach { subview in
            if subview is Circle {
                subview.removeFromSuperview()
            }
        }
    }

    
    func deployCheckerOnBoard() {
        removeAllCheckersFromView()
        removeGlowingCircleHintsFromView()
        let board = Game.shared.board // Use the singleton's board
        print("Holding piece? ", Game.shared.state)

        for (rowIndex, row) in board.enumerated() {
            for (columnIndex, cell) in row.enumerated() {
                switch cell {
                case "#", "@":
                    let checkerColor: Checker.Color = cell == "#" ? .black : .white
                    self.addChecker(at: rowIndex, column: columnIndex, color: checkerColor)
                    
                    // Check if this checker is movable
                    let coordinate = Coordinate(row: rowIndex, col: columnIndex)
                    
                    if Game.shared.state == .choice {
                        let movableCheckers = Game.shared.findMovableCheckers()
                        if movableCheckers.contains(coordinate) {
                            // Add a glow effect to the checker
                            addGlowEffect(toCheckerAt: rowIndex, column: columnIndex)
                        }
                    }
                
                case ".":
                    let coordinate = Coordinate(row: rowIndex, col: columnIndex)

                    if Game.shared.state == .hint {
                        let possiblePlaces = Game.shared.findPossibleMoveDestination()

//                        let possiblePlaces = Game.shared.possibleDropPoint()
                        if possiblePlaces.contains(coordinate) {
                            addGlowingCircle(at: rowIndex, column: columnIndex)
                        }
                    }
                default:
                    
                    continue
                }
            }
        }
    }

    private func addGlowEffect(toCheckerAt row: Int, column: Int) {
        // Assuming you have a way to get the specific checker view, e.g., via a tag or storing references
        guard let checker = self.subviews.first(where: { $0 is Checker && $0.tag == (row * 8 + column) }) as? Checker else {
            return
        }
        
        checker.layer.shadowColor = UIColor.yellow.cgColor // Choose appropriate glow color
        checker.layer.shadowOpacity = 0.8
        checker.layer.shadowRadius = 10 // Adjust for desired glow effect
        checker.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    private func addGlowingCircle(at row: Int, column: Int) {
        let squareSize = self.bounds.width / 8
        let circleSize = squareSize * 0.8
        let xOffset = (squareSize - circleSize) / 2
        let yOffset = (squareSize - circleSize) / 2
        let circleFrame = CGRect(x: CGFloat(column) * squareSize + xOffset, y: CGFloat(row) * squareSize + yOffset, width: circleSize, height: circleSize)
        
        let circleView = Circle(frame: circleFrame) // Use the Circle class
        self.addSubview(circleView)
    }
    
    
    func removeAllCheckersFromView() {
        self.subviews.forEach { subview in
            if subview is Checker {
                subview.removeFromSuperview()
            }
        }
    }
}
