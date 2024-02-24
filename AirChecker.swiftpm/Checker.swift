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

