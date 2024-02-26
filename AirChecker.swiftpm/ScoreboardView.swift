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
        // Initialize and configure the score label
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 24)
        scoreLabel.textColor = .black
        addSubview(scoreLabel)
        
        // Constraints for scoreLabel
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: topAnchor),
            scoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            scoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        updateScoreDisplay() // Display initial score
    }
    
    private func updateScoreDisplay() {
        scoreLabel.text = "Score: \(score)"
    }
}
