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
        self.layer.borderWidth = 4
        // Use UIColor.white for the border color
        self.layer.borderColor = UIColor.white.cgColor
        self.backgroundColor = .clear
        
        // Remove glow effect by setting shadow properties to nil or zero
        self.layer.shadowColor = nil
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        
    }
}
