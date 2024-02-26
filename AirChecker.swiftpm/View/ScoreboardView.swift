import UIKit

class ScoreboardView: UIView {
    
    private var scoreLabel: UILabel!
    
    // Use this to set the score from outside
    var score: Int = 0 {
        didSet {
            updateScoreDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 50)
        scoreLabel.textColor = .white
        scoreLabel.layer.shadowColor = UIColor.black.cgColor
        scoreLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        scoreLabel.layer.shadowRadius = 2
        scoreLabel.layer.shadowOpacity = 0.5
        addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: topAnchor),
            scoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            scoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        updateScoreDisplay()
    }
    
    private func updateScoreDisplay() {
        scoreLabel.text = "Score: \(score)"
    }
}
