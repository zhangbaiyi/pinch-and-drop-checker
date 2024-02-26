import UIKit

class FinishView: UIView {
    private let titleLabel = UILabel()
    private var imageView = UIImageView()
    
    init(frame: CGRect, imageFrame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: imageFrame)
        if let image = UIImage(systemName: "arrow.circlepath")?.withTintColor(.white, renderingMode: .alwaysOriginal) {
            imageView.image = image
        }
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTitle(title: String) {
        titleLabel.text = title
    }
    
    
    private func setupUI() {
        backgroundColor = .clear
        
        titleLabel.text = "Title"
        titleLabel.textAlignment = .center
        titleLabel.isHidden = true
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.1
        titleLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 100)
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        titleLabel.layer.shadowRadius = 3
        titleLabel.layer.shadowOpacity = 0.8
        
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.white]
        titleLabel.attributedText = NSAttributedString(string: "Title", attributes: strokeTextAttributes)
        
        imageView.contentMode = .scaleAspectFit
        
        addSubview(titleLabel)
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 20
        titleLabel.frame = CGRect(x: padding, y: (frame.height - titleLabel.intrinsicContentSize.height) / 2, width: frame.width - (padding * 2), height: titleLabel.intrinsicContentSize.height)
    }
    
    func setTitleVisibility(_ isVisible: Bool) {
        titleLabel.isHidden = !isVisible
    }
}
