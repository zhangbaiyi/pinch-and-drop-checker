// Checker.swift

import UIKit

class Checker: UIView {
    enum Color {
        case black, white
    }
    
    var color: Color
    var location: CGPoint
    
    init(color: Color, location: CGPoint, size: CGFloat) {
        self.color = color
        self.location = location
        let frame = CGRect(x: location.x, y: location.y, width: size, height: size)
        super.init(frame: frame)
        self.backgroundColor = color == .black ? .black : .white
        self.layer.cornerRadius = size / 2 
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
