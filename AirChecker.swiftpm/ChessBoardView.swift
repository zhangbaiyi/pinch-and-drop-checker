import UIKit

class ChessBoardView: UIView {
    
    // Initialize the chess board with a specific frame or size
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
        self.addSubview(checker)
    }
    
    func deployCheckerOnBoard() {
        removeAllCheckersFromView()
        let board = Game.shared.board // Use the singleton's board
        for (rowIndex, row) in board.enumerated() {
            for (columnIndex, cell) in row.enumerated() {
                switch cell {
                case "#":
                    self.addChecker(at: rowIndex, column: columnIndex, color: .black)
                case "@":
                    self.addChecker(at: rowIndex, column: columnIndex, color: .white)
                default:
                    continue
                }
            }
        }
    }
    
    
    func removeAllCheckersFromView() {
        // Iterate over all subviews of the ChessBoardView
        self.subviews.forEach { subview in
            // Check if the subview is an instance of Checker
            if subview is Checker {
                // Remove the checker from the superview
                subview.removeFromSuperview()
            }
        }
    }
    
    
}
