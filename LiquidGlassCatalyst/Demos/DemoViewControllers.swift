import UIKit

protocol DemoPresentable: UIViewController {
    var demoTitle: String { get }
    var demoSubtitle: String { get }
    var demoSymbol: String { get }
}

@available(iOS 26.0, *)
final class ButtonsDemoViewController: UIViewController, DemoPresentable {
    let demoTitle = "Glass Buttons"
    let demoSubtitle = "System button configurations with Liquid Glass"
    let demoSymbol = "button.horizontal"

    private let stack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let configs: [(String, UIButton.Configuration)] = [
            ("Glass", .glass()),
            ("Prominent Glass", .prominentGlass()),
            ("Clear Glass", .clearGlass()),
            ("Prominent Clear", .prominentClearGlass())
        ]

        for (title, var config) in configs {
            config.title = title
            config.image = UIImage(systemName: "sparkles")
            config.imagePadding = 8
            config.buttonSize = .large

            let button = UIButton(configuration: config)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 52).isActive = true
            button.addAction(UIAction { [weak button] _ in
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                guard let button else { return }
                BounceAnimator.bounce(button)
            }, for: .primaryActionTriggered)
            stack.addArrangedSubview(button)
        }

        let hint = UILabel()
        hint.text = "Tap for a springy bounce — Liquid Glass comes free via UIButton.Configuration."
        hint.font = .preferredFont(forTextStyle: .footnote)
        hint.textColor = .secondaryLabel
        hint.numberOfLines = 0
        stack.addArrangedSubview(hint)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

@available(iOS 26.0, *)
final class TintCatalystViewController: UIViewController, DemoPresentable {
    let demoTitle = "Tint & Style"
    let demoSubtitle = "Dial tint, style, and interactivity live"
    let demoSymbol = "paintpalette"

    private var glassView: UIVisualEffectView!
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var style: GlassStyleOption = .regular
    private var interactive = true
    private var corner: GlassCornerOption = .soft
    private var tint: UIColor? = UIColor.systemCyan.withAlphaComponent(0.45)

    private let tints: [(String, UIColor?)] = [
        ("None", nil),
        ("Cyan", UIColor.systemCyan.withAlphaComponent(0.45)),
        ("Pink", UIColor.systemPink.withAlphaComponent(0.45)),
        ("Orange", UIColor.systemOrange.withAlphaComponent(0.5)),
        ("Mint", UIColor.systemMint.withAlphaComponent(0.45)),
        ("Indigo", UIColor.systemIndigo.withAlphaComponent(0.45))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        glassView = GlassFactory.makeGlassView(style: style, tint: tint, interactive: interactive, corner: corner)
        glassView.isUserInteractionEnabled = true
        view.addSubview(glassView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(glassTapped))
        glassView.addGestureRecognizer(tap)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Liquid Glass"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Tap the glass — it should bounce"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel

        glassView.contentView.addSubview(titleLabel)
        glassView.contentView.addSubview(subtitleLabel)

        let controls = UIStackView()
        controls.axis = .vertical
        controls.spacing = 14
        controls.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controls)

        controls.addArrangedSubview(makeSegment(
            title: "Style",
            items: GlassStyleOption.allCases.map(\.title),
            selected: 0
        ) { [weak self] index in
            guard let self else { return }
            self.style = GlassStyleOption.allCases[index]
            self.refresh()
        })

        controls.addArrangedSubview(makeSegment(
            title: "Corners",
            items: GlassCornerOption.allCases.map(\.title),
            selected: 2
        ) { [weak self] index in
            guard let self else { return }
            self.corner = GlassCornerOption.allCases[index]
            self.refresh()
        })

        controls.addArrangedSubview(makeTintRow())

        let interactiveSwitch = UISwitch()
        interactiveSwitch.isOn = true
        interactiveSwitch.addAction(UIAction { [weak self] action in
            guard let control = action.sender as? UISwitch else { return }
            self?.interactive = control.isOn
            self?.refresh()
        }, for: .valueChanged)

        let interactiveRow = makeLabeledRow(title: "Interactive bounce", control: interactiveSwitch)
        controls.addArrangedSubview(interactiveRow)

        NSLayoutConstraint.activate([
            glassView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glassView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36),
            glassView.widthAnchor.constraint(equalToConstant: 320),
            glassView.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.centerXAnchor.constraint(equalTo: glassView.contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: glassView.contentView.centerYAnchor, constant: -12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: glassView.contentView.centerXAnchor),

            controls.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            controls.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            controls.topAnchor.constraint(equalTo: glassView.bottomAnchor, constant: 36)
        ])
    }

    private func refresh() {
        GlassFactory.apply(style, tint: tint, interactive: interactive, corner: corner, to: glassView, animated: true)
        subtitleLabel.text = interactive ? "Tap the glass — it should bounce" : "Interactivity off"
    }

    @objc private func glassTapped() {
        guard interactive else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        BounceAnimator.bounce(glassView, scale: 0.92)
    }

    private func makeSegment(title: String, items: [String], selected: Int, onChange: @escaping (Int) -> Void) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel

        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selected
        control.addAction(UIAction { action in
            guard let control = action.sender as? UISegmentedControl else { return }
            onChange(control.selectedSegmentIndex)
        }, for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [label, control])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func makeTintRow() -> UIView {
        let label = UILabel()
        label.text = "Tint"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually

        for (name, color) in tints {
            var config = UIButton.Configuration.glass()
            config.title = name
            config.buttonSize = .small
            if let color {
                config.baseForegroundColor = color.withAlphaComponent(1)
            }
            let button = UIButton(configuration: config)
            button.addAction(UIAction { [weak self] _ in
                self?.tint = color
                self?.refresh()
            }, for: .primaryActionTriggered)
            row.addArrangedSubview(button)
        }

        let stack = UIStackView(arrangedSubviews: [label, row])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func makeLabeledRow(title: String, control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label

        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        return row
    }
}

@available(iOS 26.0, *)
final class DropletMergeViewController: UIViewController, DemoPresentable {
    let demoTitle = "Droplet Merge"
    let demoSubtitle = "Drag blobs together — they fuse like water"
    let demoSymbol = "drop.fill"

    private var containerView: UIVisualEffectView!
    private var blobs: [DraggableGlassBlob] = []
    private let spacingSlider = UISlider()
    private let spacingLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        let containerEffect = UIGlassContainerEffect()
        containerEffect.spacing = 28
        containerView = UIVisualEffectView(effect: containerEffect)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        let specs: [(String, UIColor?, String)] = [
            ("sparkles", UIColor.systemPink.withAlphaComponent(0.35), "Spark"),
            ("flame.fill", UIColor.systemOrange.withAlphaComponent(0.4), "Flame"),
            ("leaf.fill", UIColor.systemMint.withAlphaComponent(0.4), "Leaf"),
            ("moon.fill", UIColor.systemIndigo.withAlphaComponent(0.4), "Moon")
        ]

        for spec in specs {
            let blob = DraggableGlassBlob(symbolName: spec.0, tint: spec.1, title: spec.2)
            containerView.contentView.addSubview(blob)
            blobs.append(blob)
        }

        spacingLabel.translatesAutoresizingMaskIntoConstraints = false
        spacingLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        spacingLabel.textColor = .secondaryLabel
        updateSpacingLabel(28)

        spacingSlider.translatesAutoresizingMaskIntoConstraints = false
        spacingSlider.minimumValue = 0
        spacingSlider.maximumValue = 80
        spacingSlider.value = 28
        spacingSlider.addAction(UIAction { [weak self] action in
            guard let self, let slider = action.sender as? UISlider else { return }
            if let effect = self.containerView.effect as? UIGlassContainerEffect {
                effect.spacing = CGFloat(slider.value)
                self.containerView.effect = effect
            }
            self.updateSpacingLabel(CGFloat(slider.value))
        }, for: .valueChanged)

        let reset = UIButton(configuration: {
            var config = UIButton.Configuration.prominentGlass()
            config.title = "Scatter"
            config.image = UIImage(systemName: "arrow.triangle.2.circlepath")
            config.imagePadding = 6
            return config
        }())
        reset.translatesAutoresizingMaskIntoConstraints = false
        reset.addAction(UIAction { [weak self] _ in
            self?.scatter(animated: true)
        }, for: .primaryActionTriggered)

        let merge = UIButton(configuration: {
            var config = UIButton.Configuration.glass()
            config.title = "Merge"
            config.image = UIImage(systemName: "arrow.down.right.and.arrow.up.left")
            config.imagePadding = 6
            return config
        }())
        merge.translatesAutoresizingMaskIntoConstraints = false
        merge.addAction(UIAction { [weak self] _ in
            self?.mergeAll()
        }, for: .primaryActionTriggered)

        let controls = UIStackView(arrangedSubviews: [spacingLabel, spacingSlider, reset, merge])
        controls.axis = .vertical
        controls.spacing = 12
        controls.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controls)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: controls.topAnchor, constant: -16),

            controls.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            controls.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            controls.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if blobs.contains(where: { $0.frame.origin == .zero }) {
            scatter(animated: false)
        }
    }

    private func updateSpacingLabel(_ value: CGFloat) {
        spacingLabel.text = "Merge distance  ·  \(Int(value)) pt"
    }

    private func scatter(animated: Bool) {
        let area = containerView.contentView.bounds.insetBy(dx: 70, dy: 70)
        guard area.width > 0, area.height > 0 else { return }

        let positions: [CGPoint] = [
            CGPoint(x: area.minX + 40, y: area.midY - 40),
            CGPoint(x: area.maxX - 40, y: area.midY - 40),
            CGPoint(x: area.minX + 40, y: area.midY + 60),
            CGPoint(x: area.maxX - 40, y: area.midY + 60)
        ]

        let updates = {
            for (blob, point) in zip(self.blobs, positions) {
                blob.center = point
            }
        }

        if animated {
            UIView.animate(
                withDuration: 0.7,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                animations: updates
            )
        } else {
            updates()
        }
    }

    private func mergeAll() {
        let target = CGPoint(
            x: containerView.contentView.bounds.midX,
            y: containerView.contentView.bounds.midY - 20
        )
        UIView.animate(
            withDuration: 0.85,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.4
        ) {
            for blob in self.blobs {
                blob.center = target
            }
        }
    }
}

@available(iOS 26.0, *)
final class MaterializeDemoViewController: UIViewController, DemoPresentable {
    let demoTitle = "Materialize"
    let demoSubtitle = "Glass appears and dissolves with the system animation"
    let demoSymbol = "wand.and.stars"

    private var glassView: UIVisualEffectView!
    private let statusLabel = UILabel()
    private var isMaterialized = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        glassView = UIVisualEffectView(effect: nil)
        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.cornerConfiguration = .corners(radius: .fixed(28))
        view.addSubview(glassView)

        let icon = UIImageView(image: UIImage(systemName: "hare.fill"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .label
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Now you see me"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center

        glassView.contentView.addSubview(icon)
        glassView.contentView.addSubview(label)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "Glass is dematerialized"
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)

        let toggle = UIButton(configuration: {
            var config = UIButton.Configuration.prominentGlass()
            config.title = "Materialize"
            config.image = UIImage(systemName: "aqi.medium")
            config.imagePadding = 8
            config.buttonSize = .large
            return config
        }())
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addAction(UIAction { [weak self, weak toggle] _ in
            self?.toggleMaterial(button: toggle)
        }, for: .primaryActionTriggered)
        view.addSubview(toggle)

        NSLayoutConstraint.activate([
            glassView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glassView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            glassView.widthAnchor.constraint(equalToConstant: 280),
            glassView.heightAnchor.constraint(equalToConstant: 160),

            icon.centerXAnchor.constraint(equalTo: glassView.contentView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: glassView.contentView.centerYAnchor, constant: -16),
            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36),

            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: glassView.contentView.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: glassView.bottomAnchor, constant: 24),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            toggle.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            toggle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggle.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])

        // Start materialized so the first impression is glass.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self, weak toggle] in
            self?.toggleMaterial(button: toggle)
        }
    }

    private func toggleMaterial(button: UIButton?) {
        isMaterialized.toggle()
        let effect: UIVisualEffect? = isMaterialized
            ? GlassFactory.makeEffect(style: .regular, tint: UIColor.systemTeal.withAlphaComponent(0.35), interactive: true)
            : nil

        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {
            self.glassView.effect = effect
            self.glassView.contentView.alpha = self.isMaterialized ? 1 : 0
        }

        statusLabel.text = isMaterialized ? "Glass is materialized" : "Glass is dematerialized"
        var config = button?.configuration ?? .prominentGlass()
        config.title = isMaterialized ? "Dematerialize" : "Materialize"
        config.image = UIImage(systemName: isMaterialized ? "rectangle.dashed" : "aqi.medium")
        button?.configuration = config
    }
}

@available(iOS 26.0, *)
final class FloatingControlsDemoViewController: UIViewController, DemoPresentable {
    let demoTitle = "Floating Cluster"
    let demoSubtitle = "A Maps-style glass control cluster over content"
    let demoSymbol = "location.circle"

    private var containerView: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        let mapLike = UIView()
        mapLike.translatesAutoresizingMaskIntoConstraints = false
        mapLike.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        mapLike.layer.cornerRadius = 24
        view.addSubview(mapLike)

        let grid = makeFakeMapGrid()
        grid.translatesAutoresizingMaskIntoConstraints = false
        mapLike.addSubview(grid)

        let containerEffect = UIGlassContainerEffect()
        containerEffect.spacing = 12
        containerView = UIVisualEffectView(effect: containerEffect)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        let zoomIn = makeClusterButton(systemName: "plus", tint: nil)
        let zoomOut = makeClusterButton(systemName: "minus", tint: nil)
        let locate = makeClusterButton(systemName: "location.fill", tint: UIColor.systemBlue.withAlphaComponent(0.4))
        let layers = makeClusterButton(systemName: "square.3.layers.3d", tint: UIColor.systemPurple.withAlphaComponent(0.35))

        for button in [zoomIn, zoomOut, locate, layers] {
            containerView.contentView.addSubview(button)
        }

        NSLayoutConstraint.activate([
            mapLike.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mapLike.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            mapLike.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mapLike.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            grid.leadingAnchor.constraint(equalTo: mapLike.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: mapLike.trailingAnchor),
            grid.topAnchor.constraint(equalTo: mapLike.topAnchor),
            grid.bottomAnchor.constraint(equalTo: mapLike.bottomAnchor),

            containerView.trailingAnchor.constraint(equalTo: mapLike.trailingAnchor, constant: -18),
            containerView.bottomAnchor.constraint(equalTo: mapLike.bottomAnchor, constant: -18),
            containerView.widthAnchor.constraint(equalToConstant: 52),
            containerView.heightAnchor.constraint(equalToConstant: 236),

            zoomIn.topAnchor.constraint(equalTo: containerView.contentView.topAnchor),
            zoomIn.centerXAnchor.constraint(equalTo: containerView.contentView.centerXAnchor),
            zoomIn.widthAnchor.constraint(equalToConstant: 48),
            zoomIn.heightAnchor.constraint(equalToConstant: 48),

            zoomOut.topAnchor.constraint(equalTo: zoomIn.bottomAnchor, constant: 10),
            zoomOut.centerXAnchor.constraint(equalTo: containerView.contentView.centerXAnchor),
            zoomOut.widthAnchor.constraint(equalToConstant: 48),
            zoomOut.heightAnchor.constraint(equalToConstant: 48),

            locate.topAnchor.constraint(equalTo: zoomOut.bottomAnchor, constant: 18),
            locate.centerXAnchor.constraint(equalTo: containerView.contentView.centerXAnchor),
            locate.widthAnchor.constraint(equalToConstant: 48),
            locate.heightAnchor.constraint(equalToConstant: 48),

            layers.topAnchor.constraint(equalTo: locate.bottomAnchor, constant: 10),
            layers.centerXAnchor.constraint(equalTo: containerView.contentView.centerXAnchor),
            layers.widthAnchor.constraint(equalToConstant: 48),
            layers.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func makeClusterButton(systemName: String, tint: UIColor?) -> UIVisualEffectView {
        let glass = GlassFactory.makeGlassView(style: .regular, tint: tint, interactive: true, corner: .capsule)
        let image = UIImageView(image: UIImage(systemName: systemName))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .label
        image.contentMode = .scaleAspectFit
        glass.contentView.addSubview(image)
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: glass.contentView.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: glass.contentView.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 18),
            image.heightAnchor.constraint(equalToConstant: 18)
        ])
        return glass
    }

    private func makeFakeMapGrid() -> UIView {
        let host = UIView()
        host.isUserInteractionEnabled = false
        for i in 0..<8 {
            let h = UIView()
            h.backgroundColor = UIColor.label.withAlphaComponent(0.06)
            h.translatesAutoresizingMaskIntoConstraints = false
            host.addSubview(h)
            NSLayoutConstraint.activate([
                h.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 20),
                h.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -20),
                h.heightAnchor.constraint(equalToConstant: 1),
                h.topAnchor.constraint(equalTo: host.topAnchor, constant: CGFloat(40 + i * 48))
            ])

            let v = UIView()
            v.backgroundColor = UIColor.label.withAlphaComponent(0.06)
            v.translatesAutoresizingMaskIntoConstraints = false
            host.addSubview(v)
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: host.topAnchor, constant: 20),
                v.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -20),
                v.widthAnchor.constraint(equalToConstant: 1),
                v.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: CGFloat(50 + i * 70))
            ])
        }

        let pin = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        pin.tintColor = .systemRed
        pin.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(pin)
        NSLayoutConstraint.activate([
            pin.centerXAnchor.constraint(equalTo: host.centerXAnchor, constant: -40),
            pin.centerYAnchor.constraint(equalTo: host.centerYAnchor, constant: 20),
            pin.widthAnchor.constraint(equalToConstant: 44),
            pin.heightAnchor.constraint(equalToConstant: 44)
        ])
        return host
    }
}
