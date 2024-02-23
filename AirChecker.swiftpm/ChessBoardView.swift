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
                // Set the backgroundColor with alpha 0.5
                if (row + column) % 2 == 0 {
                    square.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                } else {
                    square.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                }
                self.addSubview(square)
            }
        }
    }
    
    // Add methods for managing chess pieces here
}
