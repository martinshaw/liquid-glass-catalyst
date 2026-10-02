import UIKit

final class CatalystViewController: UIViewController {
    private let backdrop = AnimatedMeshBackdrop()
    private let contentContainer = UIView()
    private var sidebar: UIVisualEffectView?
    private var stage: UIVisualEffectView?
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var demoHost = UIView()
    private var currentDemo: UIViewController?
    private var demoButtons: [UIButton] = []
    private var selectedIndex = 0

    private lazy var demos: [any DemoPresentable] = {
        if #available(iOS 26.0, *) {
            return [
                ControlsFidgetDemoViewController(),
                ButtonsDemoViewController(),
                TintCatalystViewController(),
                DropletMergeViewController(),
                MaterializeDemoViewController(),
                FloatingControlsDemoViewController()
            ]
        }
        return []
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        backdrop.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdrop)

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)

        NSLayoutConstraint.activate([
            backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdrop.topAnchor.constraint(equalTo: view.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        if #available(iOS 26.0, *) {
            buildCatalyst()
        } else {
            buildFallback()
        }
    }

    @available(iOS 26.0, *)
    private func buildCatalyst() {
        let sidebarEffect = UIGlassEffect(style: .regular)
        sidebarEffect.isInteractive = false
        let sidebarView = UIVisualEffectView(effect: sidebarEffect)
        sidebarView.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.cornerConfiguration = .corners(radius: .fixed(28))
        contentContainer.addSubview(sidebarView)
        sidebar = sidebarView

        let brand = UILabel()
        brand.translatesAutoresizingMaskIntoConstraints = false
        brand.text = "Liquid Glass"
        brand.font = .systemFont(ofSize: 22, weight: .bold)
        brand.textColor = .label

        let brandSub = UILabel()
        brandSub.translatesAutoresizingMaskIntoConstraints = false
        brandSub.text = "UIKit Catalyst"
        brandSub.font = .systemFont(ofSize: 13, weight: .medium)
        brandSub.textColor = .secondaryLabel

        let navStack = UIStackView()
        navStack.axis = .vertical
        navStack.spacing = 8
        navStack.translatesAutoresizingMaskIntoConstraints = false

        for (index, demo) in demos.enumerated() {
            var config = UIButton.Configuration.glass()
            config.title = demo.demoTitle
            config.image = UIImage(systemName: demo.demoSymbol)
            config.imagePadding = 10
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
            config.baseForegroundColor = .label

            let button = UIButton(configuration: config)
            button.tag = index
            button.addAction(UIAction { [weak self] action in
                guard let button = action.sender as? UIButton else { return }
                self?.selectDemo(at: button.tag)
            }, for: .primaryActionTriggered)
            demoButtons.append(button)
            navStack.addArrangedSubview(button)
        }

        let paletteButton = UIButton(configuration: {
            var config = UIButton.Configuration.clearGlass()
            config.title = "Shuffle backdrop"
            config.image = UIImage(systemName: "circle.hexagongrid.fill")
            config.imagePadding = 8
            return config
        }())
        paletteButton.addAction(UIAction { [weak self] _ in
            self?.shuffleBackdrop()
        }, for: .primaryActionTriggered)

        sidebarView.contentView.addSubview(brand)
        sidebarView.contentView.addSubview(brandSub)
        sidebarView.contentView.addSubview(navStack)
        sidebarView.contentView.addSubview(paletteButton)
        paletteButton.translatesAutoresizingMaskIntoConstraints = false

        let stage = UIVisualEffectView(effect: UIGlassEffect(style: .clear))
        stage.translatesAutoresizingMaskIntoConstraints = false
        stage.cornerConfiguration = .corners(radius: .fixed(32))
        stage.clipsToBounds = true
        contentContainer.addSubview(stage)
        self.stage = stage

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        demoHost.translatesAutoresizingMaskIntoConstraints = false
        demoHost.backgroundColor = .clear
        demoHost.clipsToBounds = true

        stage.contentView.addSubview(titleLabel)
        stage.contentView.addSubview(subtitleLabel)
        stage.contentView.addSubview(demoHost)

        NSLayoutConstraint.activate([
            sidebarView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 20),
            sidebarView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 20),
            sidebarView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -20),
            sidebarView.widthAnchor.constraint(equalToConstant: 250),

            brand.leadingAnchor.constraint(equalTo: sidebarView.contentView.leadingAnchor, constant: 20),
            brand.trailingAnchor.constraint(equalTo: sidebarView.contentView.trailingAnchor, constant: -20),
            brand.topAnchor.constraint(equalTo: sidebarView.contentView.topAnchor, constant: 24),

            brandSub.leadingAnchor.constraint(equalTo: brand.leadingAnchor),
            brandSub.topAnchor.constraint(equalTo: brand.bottomAnchor, constant: 2),

            navStack.leadingAnchor.constraint(equalTo: sidebarView.contentView.leadingAnchor, constant: 12),
            navStack.trailingAnchor.constraint(equalTo: sidebarView.contentView.trailingAnchor, constant: -12),
            navStack.topAnchor.constraint(equalTo: brandSub.bottomAnchor, constant: 28),

            paletteButton.leadingAnchor.constraint(equalTo: sidebarView.contentView.leadingAnchor, constant: 12),
            paletteButton.trailingAnchor.constraint(equalTo: sidebarView.contentView.trailingAnchor, constant: -12),
            paletteButton.bottomAnchor.constraint(equalTo: sidebarView.contentView.bottomAnchor, constant: -18),

            stage.leadingAnchor.constraint(equalTo: sidebarView.trailingAnchor, constant: 16),
            stage.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -20),
            stage.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 20),
            stage.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -20),

            titleLabel.leadingAnchor.constraint(equalTo: stage.contentView.leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: stage.contentView.trailingAnchor, constant: -28),
            titleLabel.topAnchor.constraint(equalTo: stage.contentView.topAnchor, constant: 24),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            demoHost.leadingAnchor.constraint(equalTo: stage.contentView.leadingAnchor),
            demoHost.trailingAnchor.constraint(equalTo: stage.contentView.trailingAnchor),
            demoHost.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            demoHost.bottomAnchor.constraint(equalTo: stage.contentView.bottomAnchor)
        ])

        selectDemo(at: 0)
    }

    private func buildFallback() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Liquid Glass requires the iOS / macOS 26 SDK\nand Xcode 26+."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func selectDemo(at index: Int) {
        guard demos.indices.contains(index) else { return }
        selectedIndex = index
        let demo = demos[index]

        titleLabel.text = demo.demoTitle
        subtitleLabel.text = demo.demoSubtitle

        if #available(iOS 26.0, *) {
            for (buttonIndex, button) in demoButtons.enumerated() {
                var config = button.configuration ?? .glass()
                config = buttonIndex == index ? .prominentGlass() : .glass()
                config.title = demos[buttonIndex].demoTitle
                config.image = UIImage(systemName: demos[buttonIndex].demoSymbol)
                config.imagePadding = 10
                config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
                button.configuration = config
            }
        }

        if let currentDemo {
            currentDemo.willMove(toParent: nil)
            currentDemo.view.removeFromSuperview()
            currentDemo.removeFromParent()
        }

        addChild(demo)
        demo.view.translatesAutoresizingMaskIntoConstraints = false
        demo.view.alpha = 0
        demo.view.transform = CGAffineTransform(translationX: 0, y: 12)
        demoHost.addSubview(demo.view)
        NSLayoutConstraint.activate([
            demo.view.leadingAnchor.constraint(equalTo: demoHost.leadingAnchor),
            demo.view.trailingAnchor.constraint(equalTo: demoHost.trailingAnchor),
            demo.view.topAnchor.constraint(equalTo: demoHost.topAnchor),
            demo.view.bottomAnchor.constraint(equalTo: demoHost.bottomAnchor)
        ])
        demo.didMove(toParent: self)
        currentDemo = demo

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.4
        ) {
            demo.view.alpha = 1
            demo.view.transform = .identity
        }
    }

    private func shuffleBackdrop() {
        let palettes: [[UIColor]] = [
            [
                UIColor(red: 0.98, green: 0.42, blue: 0.38, alpha: 1),
                UIColor(red: 0.99, green: 0.72, blue: 0.28, alpha: 1),
                UIColor(red: 0.28, green: 0.72, blue: 0.92, alpha: 1)
            ],
            [
                UIColor(red: 0.20, green: 0.85, blue: 0.70, alpha: 1),
                UIColor(red: 0.35, green: 0.55, blue: 0.98, alpha: 1),
                UIColor(red: 0.90, green: 0.40, blue: 0.80, alpha: 1)
            ],
            [
                UIColor(red: 1.00, green: 0.55, blue: 0.20, alpha: 1),
                UIColor(red: 0.95, green: 0.25, blue: 0.45, alpha: 1),
                UIColor(red: 0.55, green: 0.20, blue: 0.90, alpha: 1)
            ],
            [
                UIColor(red: 0.25, green: 0.90, blue: 0.45, alpha: 1),
                UIColor(red: 0.20, green: 0.70, blue: 0.95, alpha: 1),
                UIColor(red: 0.95, green: 0.85, blue: 0.25, alpha: 1)
            ]
        ]
        backdrop.palette = palettes.randomElement() ?? palettes[0]
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
