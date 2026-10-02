import UIKit

/// Draggable glass droplet used in the merge catalyst.
@available(iOS 26.0, *)
final class DraggableGlassBlob: UIVisualEffectView {
    private let symbolView = UIImageView()
    private let titleLabel = UILabel()
    var onMoved: (() -> Void)?

    init(symbolName: String, tint: UIColor?, title: String) {
        let effect = GlassFactory.makeEffect(style: .regular, tint: tint, interactive: true)
        super.init(effect: effect)
        cornerConfiguration = .capsule()
        translatesAutoresizingMaskIntoConstraints = false

        symbolView.translatesAutoresizingMaskIntoConstraints = false
        symbolView.contentMode = .scaleAspectFit
        symbolView.tintColor = .label
        symbolView.image = UIImage(systemName: symbolName)?.withRenderingMode(.alwaysTemplate)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        contentView.addSubview(symbolView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 108),
            heightAnchor.constraint(equalToConstant: 108),
            symbolView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            symbolView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            symbolView.widthAnchor.constraint(equalToConstant: 28),
            symbolView.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.topAnchor.constraint(equalTo: symbolView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview else { return }
        let translation = gesture.translation(in: superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)
        onMoved?()

        if gesture.state == .began {
            UIView.animate(withDuration: 0.18) {
                self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            UIView.animate(
                withDuration: 0.55,
                delay: 0,
                usingSpringWithDamping: 0.55,
                initialSpringVelocity: 0.8
            ) {
                self.transform = .identity
            }
        }
    }
}
