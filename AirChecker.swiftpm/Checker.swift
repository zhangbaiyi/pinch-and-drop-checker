// Checker.swift

import UIKit

class Checker: UIView {
    // Enum for checker color
    enum Color {
        case black, white
    }
    
    // Properties for color and location
    var color: Color
    var location: CGPoint
    
    // Initialize the checker with color and location
    init(color: Color, location: CGPoint, size: CGFloat) {
        self.color = color
        self.location = location
        let frame = CGRect(x: location.x, y: location.y, width: size, height: size)
        super.init(frame: frame)
        self.backgroundColor = color == .black ? .black : .white
        self.layer.cornerRadius = size / 2 // Make the view circular
        
        self.layer.borderWidth = 2
        self.layer.borderColor = color == .black ? UIColor.white.cgColor : UIColor.black.cgColor
            
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(_ selected: Bool) {
        self.layer.borderColor = selected ? UIColor.green.cgColor : (color == .black ? UIColor.white.cgColor : UIColor.black.cgColor)
    }
}

// Extension to ChessBoardView to manage checkers
extension ChessBoardView {
    func addChecker(at row: Int, column: Int, color: Checker.Color) {
        let squareSize = self.bounds.width / 8
        let checkerSize = squareSize * 0.8 // Checkers are slightly smaller than the squares
        let xOffset = (squareSize - checkerSize) / 2
        let yOffset = (squareSize - checkerSize) / 2
        let checker = Checker(color: color, location: CGPoint(x: CGFloat(column) * squareSize + xOffset, y: CGFloat(row) * squareSize + yOffset), size: checkerSize)
        self.addSubview(checker)
    }
}
