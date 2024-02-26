import UIKit

class Checker: UIView {
    enum Color {
        case black, white
    }
    
    var color: Color
    var location: CGPoint
    var king: Bool = false {
        didSet {
            addCrownIconIfNeeded()
        }
    }
    
    private var crownIconView: UIImageView?
    
    init(color: Color, location: CGPoint, size: CGFloat, king: Bool = false) {
        self.color = color
        self.location = location
        self.king = king
        let frame = CGRect(x: location.x, y: location.y, width: size, height: size)
        super.init(frame: frame)
        self.backgroundColor = color == .black ? .black : .white
        self.layer.cornerRadius = size / 2
        self.layer.borderWidth = 2
        self.layer.borderColor = color == .black ? UIColor.white.cgColor : UIColor.black.cgColor
        addCrownIconIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addCrownIconIfNeeded() {
        crownIconView?.removeFromSuperview()
        if king {
            let crownImage = UIImage(systemName: "crown")
            let imageView = UIImageView(image: crownImage)
            imageView.contentMode = .scaleAspectFit
            let padding: CGFloat = 5
            let iconSize: CGFloat = min(bounds.width, bounds.height) * 0.75 - padding
            imageView.frame = CGRect(x: (bounds.width - iconSize) / 2, y: (bounds.height - iconSize) / 2, width: iconSize, height: iconSize)
            addSubview(imageView)
            crownIconView = imageView
            
            if let borderColor = self.layer.borderColor {
                imageView.tintColor = UIColor(cgColor: borderColor)
            }
        }
    }
    
    func setSelected(_ selected: Bool) {
        self.layer.borderColor = selected ? UIColor.green.cgColor : (color == .black ? UIColor.white.cgColor : UIColor.black.cgColor)
    }
}
