import Foundation
import UIKit

class WinningView: UIView {
    private let emojis = ["🎉", "🥳", "👍", "❤️", "👑", "🥇"]
    private var animator: UIDynamicAnimator!
    private var gravity: UIGravityBehavior!
    private var collision: UICollisionBehavior!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupAnimator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startFallingEmojisStaggered() {
        // Using DispatchQueue is not necessary for Timer.scheduledTimer
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
            self?.dropEmoji()
        }
    }

    private func dropEmoji() {
        guard let emoji = emojis.randomElement() else { return }
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: CGFloat(arc4random_uniform(40) + 40))
        let xPosition = CGFloat(arc4random_uniform(UInt32(self.frame.width)))
        emojiLabel.frame = CGRect(x: xPosition, y: 0, width: 80, height: 80)
        addSubview(emojiLabel)
        
        gravity.addItem(emojiLabel)
        collision.addItem(emojiLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            self.gravity.removeItem(emojiLabel)
            self.collision.removeItem(emojiLabel)
            emojiLabel.removeFromSuperview()
        }
    }
    
    private func setupAnimator() {
        animator = UIDynamicAnimator(referenceView: self)
        
        gravity = UIGravityBehavior()
        gravity.magnitude = 1.0 // Adjust for different gravity effects
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior()
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
    }
}
