import UIKit

enum BounceAnimator {
    /// Satisfying press: squash, then spring back with overshoot.
    static func bounce(_ view: UIView, scale: CGFloat = 0.88) {
        view.layer.removeAllAnimations()
        view.transform = .identity

        UIView.animate(
            withDuration: 0.12,
            delay: 0,
            options: [.curveEaseIn, .allowUserInteraction]
        ) {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            UIView.animate(
                withDuration: 0.55,
                delay: 0,
                usingSpringWithDamping: 0.28,
                initialSpringVelocity: 8.5,
                options: [.allowUserInteraction]
            ) {
                view.transform = .identity
            }
        }
    }
}
