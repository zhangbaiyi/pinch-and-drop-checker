import UIKit

class Circle: UIView {
    init(frame: CGRect, color: UIColor = UIColor.green) {
        super.init(frame: frame)
        setupView(color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(color: UIColor) {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.backgroundColor = .clear
        self.alpha = 0.75 // Set the opacity of the view to 0.75
        
        // Create a CAShapeLayer to draw the dotted line
//        let shapeLayer = CAShapeLayer()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineCap = .round
        shapeLayer.lineDashPattern = [10, 10]
        
//        shapeLayer.strokeColor = UIColor.white.cgColor
//        shapeLayer.lineWidth = 4
//        // Dash pattern: [line segment, gap] - e.g., [4, 2] means 4 points of line and 2 points of gap
//        shapeLayer.lineDashPattern = [4, 2]
        
        // Create a circular path
        let rect = bounds.insetBy(dx: shapeLayer.lineWidth / 2, dy: shapeLayer.lineWidth / 2)
       let radius = min(rect.width, rect.height) / 2
       let center = CGPoint(x: rect.midX, y: rect.midY)
       let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
       shapeLayer.path = path.cgPath
        
        // Remove any existing border or shadow
        self.layer.borderWidth = 0
        self.layer.shadowColor = nil
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        // Add the dotted line layer as a sublayer
        self.layer.addSublayer(shapeLayer)
    }
}
