import UIKit

enum GlassStyleOption: String, CaseIterable {
    case regular
    case clear

    var title: String {
        switch self {
        case .regular: "Regular"
        case .clear: "Clear"
        }
    }

    @available(iOS 26.0, *)
    var glassStyle: UIGlassEffect.Style {
        switch self {
        case .regular: .regular
        case .clear: .clear
        }
    }
}

enum GlassCornerOption: String, CaseIterable {
    case capsule
    case rounded
    case soft
    case container

    var title: String {
        switch self {
        case .capsule: "Capsule"
        case .rounded: "Rounded"
        case .soft: "Soft"
        case .container: "Concentric"
        }
    }

    @available(iOS 26.0, *)
    var configuration: UICornerConfiguration {
        switch self {
        case .capsule:
            .capsule()
        case .rounded:
            .corners(radius: .fixed(22))
        case .soft:
            .corners(radius: .fixed(36))
        case .container:
            .corners(radius: .containerConcentric())
        }
    }
}

@available(iOS 26.0, *)
enum GlassFactory {
    static func makeEffect(
        style: GlassStyleOption = .regular,
        tint: UIColor? = nil,
        interactive: Bool = true
    ) -> UIGlassEffect {
        let effect = UIGlassEffect(style: style.glassStyle)
        effect.tintColor = tint
        effect.isInteractive = interactive
        return effect
    }

    static func makeGlassView(
        style: GlassStyleOption = .regular,
        tint: UIColor? = nil,
        interactive: Bool = true,
        corner: GlassCornerOption = .capsule
    ) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: makeEffect(style: style, tint: tint, interactive: interactive))
        view.cornerConfiguration = corner.configuration
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func apply(
        _ style: GlassStyleOption,
        tint: UIColor?,
        interactive: Bool,
        corner: GlassCornerOption,
        to effectView: UIVisualEffectView,
        animated: Bool
    ) {
        let next = makeEffect(style: style, tint: tint, interactive: interactive)
        let updates = {
            effectView.effect = next
            effectView.cornerConfiguration = corner.configuration
        }
        if animated {
            UIView.animate(withDuration: 0.45, delay: 0, options: [.curveEaseInOut]) {
                updates()
            }
        } else {
            updates()
        }
    }
}
