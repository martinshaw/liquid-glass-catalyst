import UIKit

/// Nostalgic full-kit fidget board — classic UIKit controls under Liquid Glass.
/// Avoids Mac-idiom Catalyst crashers: UIStepper, UIPickerView, date wheels, slider value images.
@available(iOS 26.0, *)
final class ControlsFidgetDemoViewController: UIViewController, DemoPresentable {
    let demoTitle = "Fidget Kit"
    let demoSubtitle = "Every classic control, ready to poke and spin"
    let demoSymbol = "slider.horizontal.2.square.on.square"

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let statusLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let activity = UIActivityIndicatorView(style: .large)
    private let volumeSlider = UISlider()
    private let brightnessSlider = UISlider()
    private let countValueLabel = UILabel()
    private let pageControl = UIPageControl()
    private let switchA = UISwitch()
    private let switchB = UISwitch()
    private let switchC = UISwitch()
    private let segment = UISegmentedControl(items: ["Aqua", "Graphite", "Clear"])
    private let textField = UITextField()
    private let textView = UITextView()
    private let datePicker = UIDatePicker()
    private let colorWell = UIColorWell()
    private let searchField = UISearchTextField()

    private var countValue = 3 {
        didSet {
            countValueLabel.text = "\(countValue)"
            pageControl.currentPage = min(countValue, max(0, pageControl.numberOfPages - 1))
        }
    }

    private let pickerColumns = [
        ["Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink"],
        ["Delicious", "Delightful", "Dubious", "Dramatic", "Dainty"],
        ["Mac", "iPod", "Cube", "Clamshell", "Cinema"]
    ]
    private var pickerSelections = [4, 1, 0]
    private var pickerButtons: [UIButton] = []

    private var isMacIdiom: Bool {
        traitCollection.userInterfaceIdiom == .mac
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -28),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])

        buildBoard()
        ping("Ready. Fidget freely.")
    }

    private func buildBoard() {
        contentStack.addArrangedSubview(makeHeroStatus())

        contentStack.addArrangedSubview(section("Buttons", symbol: "button.programmable") {
            makeButtonRow()
        })

        contentStack.addArrangedSubview(section("Toggles", symbol: "switch.2") {
            makeToggleBlock()
        })

        contentStack.addArrangedSubview(section("Sliders", symbol: "slider.horizontal.3") {
            makeSliderBlock()
        })

        contentStack.addArrangedSubview(section("Counter · Progress · Spinner", symbol: "plusminus.circle") {
            makeCounterProgressBlock()
        })

        contentStack.addArrangedSubview(section("Segments · Pages · Color", symbol: "rectangle.split.3x1") {
            makeSegmentPageColorBlock()
        })

        contentStack.addArrangedSubview(section("Text", symbol: "character.cursor.ibeam") {
            makeTextBlock()
        })

        contentStack.addArrangedSubview(section("Date & Time", symbol: "calendar") {
            makeDateBlock()
        })

        contentStack.addArrangedSubview(section("Pickers", symbol: "line.3.horizontal.decrease") {
            makePickerBlock()
        })

        contentStack.addArrangedSubview(section("Menus & More", symbol: "filemenu.and.selection") {
            makeMenusBlock()
        })

        let footer = UILabel()
        footer.text = "Tip: Liquid Glass rides along on system controls automatically — flip switches, scrub sliders, open menus."
        footer.font = .preferredFont(forTextStyle: .footnote)
        footer.textColor = .secondaryLabel
        footer.numberOfLines = 0
        contentStack.addArrangedSubview(footer)
    }

    // MARK: - Sections

    private func makeHeroStatus() -> UIView {
        let panel = glassPanel()

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        statusLabel.textColor = .label
        statusLabel.numberOfLines = 2
        statusLabel.textAlignment = .center

        let eyebrow = UILabel()
        eyebrow.translatesAutoresizingMaskIntoConstraints = false
        eyebrow.text = "CONTROL STRIP"
        eyebrow.font = .systemFont(ofSize: 11, weight: .bold)
        eyebrow.textColor = .secondaryLabel

        panel.contentView.addSubview(eyebrow)
        panel.contentView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            eyebrow.topAnchor.constraint(equalTo: panel.contentView.topAnchor, constant: 14),
            eyebrow.centerXAnchor.constraint(equalTo: panel.contentView.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: eyebrow.bottomAnchor, constant: 6),
            statusLabel.leadingAnchor.constraint(equalTo: panel.contentView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: panel.contentView.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(equalTo: panel.contentView.bottomAnchor, constant: -16)
        ])
        return panel
    }

    private func makeButtonRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually

        let specs: [(String, UIButton.Configuration, String)] = [
            ("Glass", .glass(), "sparkles"),
            ("Filled", .prominentGlass(), "checkmark.circle.fill"),
            ("Clear", .clearGlass(), "drop"),
            ("Tinted", .prominentClearGlass(), "paintbrush.pointed")
        ]

        for (title, var config, symbol) in specs {
            config.title = title
            config.image = UIImage(systemName: symbol)
            config.imagePadding = 6
            config.buttonSize = .medium
            let button = UIButton(configuration: config)
            button.addAction(UIAction { [weak self] _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self?.ping("Button · \(title)")
            }, for: .primaryActionTriggered)
            row.addArrangedSubview(button)
        }
        return row
    }

    private func makeToggleBlock() -> UIView {
        switchA.isOn = true
        switchB.isOn = false
        switchC.isOn = true
        switchA.addAction(UIAction { [weak self] a in
            guard let s = a.sender as? UISwitch else { return }
            self?.ping("Switch A · \(s.isOn ? "on" : "off")")
        }, for: .valueChanged)
        switchB.addAction(UIAction { [weak self] a in
            guard let s = a.sender as? UISwitch else { return }
            self?.ping("Switch B · \(s.isOn ? "on" : "off")")
            if s.isOn {
                self?.activity.startAnimating()
            } else {
                self?.activity.stopAnimating()
            }
        }, for: .valueChanged)
        switchC.addAction(UIAction { [weak self] a in
            guard let s = a.sender as? UISwitch else { return }
            self?.ping("Night mode fantasy · \(s.isOn ? "on" : "off")")
            self?.view.window?.overrideUserInterfaceStyle = s.isOn ? .dark : .unspecified
        }, for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [
            labeledRow("Wi‑Fi nostalgia", switchA),
            labeledRow("Spin the beachball", switchB),
            labeledRow("Force dark chrome", switchC)
        ])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }

    private func makeSliderBlock() -> UIView {
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        volumeSlider.value = 0.55
        volumeSlider.addAction(UIAction { [weak self] a in
            guard let s = a.sender as? UISlider else { return }
            self?.progressView.setProgress(s.value, animated: true)
            self?.ping(String(format: "Volume · %.0f%%", s.value * 100))
        }, for: .valueChanged)

        brightnessSlider.minimumValue = 0
        brightnessSlider.maximumValue = 10
        brightnessSlider.value = 7
        brightnessSlider.trackConfiguration = .init(
            allowsTickValuesOnly: true,
            numberOfTicks: 11
        )
        brightnessSlider.addAction(UIAction { [weak self] a in
            guard let s = a.sender as? UISlider else { return }
            self?.ping(String(format: "Brightness · %.0f", s.value))
        }, for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [
            caption("Volume (drives progress)"),
            volumeSlider,
            caption("Brightness"),
            brightnessSlider
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func makeCounterProgressBlock() -> UIView {
        // UIStepper is unsupported in Mac-idiom Catalyst — use glass +/- buttons.
        countValueLabel.font = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        countValueLabel.textColor = .label
        countValueLabel.text = "\(countValue)"
        countValueLabel.textAlignment = .center
        countValueLabel.setContentHuggingPriority(.required, for: .horizontal)
        countValueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

        let minus = makeIconButton(systemName: "minus")
        minus.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.countValue = max(0, self.countValue - 1)
            self.ping("Counter · \(self.countValue)")
        }, for: .primaryActionTriggered)

        let plus = makeIconButton(systemName: "plus")
        plus.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.countValue = min(42, self.countValue + 1)
            self.ping("Counter · \(self.countValue)")
        }, for: .primaryActionTriggered)

        progressView.progress = 0.55
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.heightAnchor.constraint(equalToConstant: 6).isActive = true

        activity.hidesWhenStopped = false
        activity.startAnimating()

        let top = UIStackView(arrangedSubviews: [minus, countValueLabel, plus, UIView(), activity])
        top.axis = .horizontal
        top.alignment = .center
        top.spacing = 14

        let bump = UIButton(configuration: {
            var c = UIButton.Configuration.glass()
            c.title = "Nudge progress"
            c.image = UIImage(systemName: "chart.bar.fill")
            c.imagePadding = 6
            return c
        }())
        bump.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let next = min(1, self.progressView.progress + 0.08)
            self.progressView.setProgress(next, animated: true)
            self.volumeSlider.setValue(next, animated: true)
            self.ping(String(format: "Progress · %.0f%%", next * 100))
            if next >= 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.progressView.setProgress(0, animated: true)
                    self.volumeSlider.setValue(0, animated: true)
                    self.ping("Progress reset — classic.")
                }
            }
        }, for: .primaryActionTriggered)

        let stack = UIStackView(arrangedSubviews: [top, caption("Progress"), progressView, bump])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    private func makeSegmentPageColorBlock() -> UIView {
        segment.selectedSegmentIndex = 0
        segment.addAction(UIAction { [weak self] a in
            guard let s = a.sender as? UISegmentedControl else { return }
            let name = s.titleForSegment(at: s.selectedSegmentIndex) ?? "?"
            self?.ping("Segment · \(name)")
        }, for: .valueChanged)

        pageControl.numberOfPages = 7
        pageControl.currentPage = 2
        pageControl.backgroundStyle = .prominent
        pageControl.addAction(UIAction { [weak self] a in
            guard let self, let p = a.sender as? UIPageControl else { return }
            self.countValue = p.currentPage
            self.ping("Page · \(p.currentPage + 1) of \(p.numberOfPages)")
        }, for: .valueChanged)

        colorWell.selectedColor = .systemTeal
        colorWell.title = "Accent"
        colorWell.supportsAlpha = true
        colorWell.addAction(UIAction { [weak self] a in
            guard let well = a.sender as? UIColorWell else { return }
            self?.view.tintColor = well.selectedColor
            self?.progressView.progressTintColor = well.selectedColor
            self?.ping("Color well · accent updated")
        }, for: .valueChanged)

        let colorRow = UIStackView(arrangedSubviews: [
            caption("Color well"),
            UIView(),
            colorWell
        ])
        colorRow.axis = .horizontal
        colorRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [
            caption("Look"),
            segment,
            caption("Pages"),
            pageControl,
            colorRow
        ])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    private func makeTextBlock() -> UIView {
        searchField.placeholder = "Spotlight something silly…"
        searchField.borderStyle = .none
        searchField.addAction(UIAction { [weak self] a in
            guard let f = a.sender as? UISearchTextField else { return }
            let t = f.text ?? ""
            self?.ping(t.isEmpty ? "Search cleared" : "Search · \(t)")
        }, for: .editingChanged)

        textField.placeholder = "Type like it’s TextEdit"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addAction(UIAction { [weak self] a in
            guard let f = a.sender as? UITextField else { return }
            self?.ping("Field · \(f.text ?? "")")
        }, for: .editingChanged)

        textView.text = "Dear Diary,\n\nToday I discovered Liquid Glass and immediately began clicking every switch in sight."
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.55)
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        textView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        textView.delegate = self

        let stack = UIStackView(arrangedSubviews: [
            caption("Search"),
            searchField,
            caption("Text field"),
            textField,
            caption("Text view"),
            textView
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func makeDateBlock() -> UIView {
        datePicker.datePickerMode = .dateAndTime
        // Wheels crash on Mac-idiom Catalyst — keep Compact/Inline there.
        datePicker.preferredDatePickerStyle = isMacIdiom ? .compact : .wheels
        datePicker.addAction(UIAction { [weak self] a in
            guard let p = a.sender as? UIDatePicker else { return }
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            self?.ping("Date · \(f.string(from: p.date))")
        }, for: .valueChanged)

        let items = isMacIdiom ? ["Compact", "Inline"] : ["Wheels", "Compact", "Inline"]
        let style = UISegmentedControl(items: items)
        style.selectedSegmentIndex = isMacIdiom ? 0 : 0
        style.addAction(UIAction { [weak self] a in
            guard let self, let s = a.sender as? UISegmentedControl else { return }
            let title = s.titleForSegment(at: s.selectedSegmentIndex) ?? ""
            switch title {
            case "Inline":
                self.datePicker.preferredDatePickerStyle = .inline
            case "Wheels":
                self.datePicker.preferredDatePickerStyle = .wheels
            default:
                self.datePicker.preferredDatePickerStyle = .compact
            }
            self.ping("Date style · \(title)")
        }, for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [style, datePicker])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    private func makePickerBlock() -> UIView {
        // UIPickerView is unsupported in Mac-idiom Catalyst — use menu buttons instead.
        pickerButtons.removeAll()
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually

        for (column, options) in pickerColumns.enumerated() {
            let selected = options[pickerSelections[column]]
            var config = UIButton.Configuration.glass()
            config.title = selected
            config.image = UIImage(systemName: "chevron.up.chevron.down")
            config.imagePlacement = .trailing
            config.imagePadding = 6
            config.buttonSize = .medium

            let button = UIButton(configuration: config)
            button.changesSelectionAsPrimaryAction = true
            button.showsMenuAsPrimaryAction = true
            button.menu = UIMenu(children: options.enumerated().map { index, title in
                UIAction(title: title, state: index == self.pickerSelections[column] ? .on : .off) { [weak self, weak button] _ in
                    guard let self else { return }
                    self.pickerSelections[column] = index
                    var updated = button?.configuration ?? .glass()
                    updated.title = title
                    updated.image = UIImage(systemName: "chevron.up.chevron.down")
                    updated.imagePlacement = .trailing
                    updated.imagePadding = 6
                    button?.configuration = updated
                    button?.menu = self.menuForPickerColumn(column)
                    self.pingPicker()
                }
            })
            pickerButtons.append(button)
            row.addArrangedSubview(button)
        }

        let stack = UIStackView(arrangedSubviews: [
            caption("Pop-up pickers (Mac-safe stand-in for wheels)"),
            row
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func menuForPickerColumn(_ column: Int) -> UIMenu {
        let options = pickerColumns[column]
        return UIMenu(children: options.enumerated().map { index, title in
            UIAction(title: title, state: index == pickerSelections[column] ? .on : .off) { [weak self] _ in
                guard let self else { return }
                self.pickerSelections[column] = index
                var updated = self.pickerButtons[column].configuration ?? .glass()
                updated.title = title
                updated.image = UIImage(systemName: "chevron.up.chevron.down")
                updated.imagePlacement = .trailing
                updated.imagePadding = 6
                self.pickerButtons[column].configuration = updated
                self.pickerButtons[column].menu = self.menuForPickerColumn(column)
                self.pingPicker()
            }
        })
    }

    private func pingPicker() {
        let phrase = pickerColumns.enumerated()
            .map { pickerColumns[$0.offset][pickerSelections[$0.offset]] }
            .joined(separator: " · ")
        ping("Picker · \(phrase)")
    }

    private func makeMenusBlock() -> UIView {
        var menuConfig = UIButton.Configuration.glass()
        menuConfig.title = "Pull-down menu"
        menuConfig.image = UIImage(systemName: "chevron.down.circle")
        menuConfig.imagePlacement = .trailing
        menuConfig.imagePadding = 8
        let menuButton = UIButton(configuration: menuConfig)
        menuButton.menu = UIMenu(title: "Classic actions", children: [
            UIAction(title: "Get Info", image: UIImage(systemName: "info.circle")) { [weak self] _ in
                self?.ping("Menu · Get Info")
            },
            UIAction(title: "Duplicate", image: UIImage(systemName: "plus.square.on.square")) { [weak self] _ in
                self?.ping("Menu · Duplicate")
            },
            UIAction(title: "Move to Trash", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.ping("Menu · Trash (jk)")
            }
        ])
        menuButton.showsMenuAsPrimaryAction = true

        var alertConfig = UIButton.Configuration.prominentGlass()
        alertConfig.title = "Sheet / alert"
        alertConfig.image = UIImage(systemName: "exclamationmark.bubble")
        alertConfig.imagePadding = 6
        let alertButton = UIButton(configuration: alertConfig)
        alertButton.addAction(UIAction { [weak self] _ in
            self?.presentFidgetAlert()
        }, for: .primaryActionTriggered)

        var shuffleConfig = UIButton.Configuration.clearGlass()
        shuffleConfig.title = "Randomize everything"
        shuffleConfig.image = UIImage(systemName: "dice")
        shuffleConfig.imagePadding = 6
        let shuffle = UIButton(configuration: shuffleConfig)
        shuffle.addAction(UIAction { [weak self] _ in
            self?.randomizeAll()
        }, for: .primaryActionTriggered)

        let stack = UIStackView(arrangedSubviews: [menuButton, alertButton, shuffle])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    // MARK: - Helpers

    private func section(_ title: String, symbol: String, @UIViewBuilder content: () -> UIView) -> UIView {
        let panel = glassPanel()

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = .secondaryLabel
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = title.uppercased()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabel

        let header = UIStackView(arrangedSubviews: [icon, label, UIView()])
        header.axis = .horizontal
        header.spacing = 6
        header.alignment = .center

        let body = content()
        let stack = UIStackView(arrangedSubviews: [header, body])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        panel.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: panel.contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: panel.contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: panel.contentView.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: panel.contentView.bottomAnchor, constant: -16),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 14)
        ])
        return panel
    }

    private func glassPanel() -> UIVisualEffectView {
        let effect = UIGlassEffect(style: .clear)
        effect.isInteractive = false
        let panel = UIVisualEffectView(effect: effect)
        panel.cornerConfiguration = .corners(radius: .fixed(20))
        panel.translatesAutoresizingMaskIntoConstraints = false
        return panel
    }

    private func makeIconButton(systemName: String) -> UIButton {
        var config = UIButton.Configuration.glass()
        config.image = UIImage(systemName: systemName)
        config.buttonSize = .medium
        let button = UIButton(configuration: config)
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return button
    }

    private func labeledRow(_ title: String, _ control: UIView) -> UIView {
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

    private func caption(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private func ping(_ message: String) {
        statusLabel.text = message
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    private func presentFidgetAlert() {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "This won’t actually delete System Folder. Probably.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.ping("Alert · Cancel")
        })
        alert.addAction(UIAlertAction(title: "Make it sparkle", style: .default) { [weak self] _ in
            self?.randomizeAll()
            self?.ping("Alert · Sparkle engaged")
        })
        alert.addAction(UIAlertAction(title: "Empty Trash…", style: .destructive) { [weak self] _ in
            self?.ping("Alert · Trash (still a joke)")
        })
        if let pop = alert.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(alert, animated: true)
    }

    private func randomizeAll() {
        switchA.setOn(.random(), animated: true)
        switchB.setOn(.random(), animated: true)
        segment.selectedSegmentIndex = Int.random(in: 0..<segment.numberOfSegments)
        volumeSlider.setValue(Float.random(in: 0...1), animated: true)
        progressView.setProgress(volumeSlider.value, animated: true)
        countValue = Int.random(in: 0...10)
        pageControl.currentPage = Int.random(in: 0..<pageControl.numberOfPages)
        for column in pickerColumns.indices {
            pickerSelections[column] = Int.random(in: 0..<pickerColumns[column].count)
            if pickerButtons.indices.contains(column) {
                var updated = pickerButtons[column].configuration ?? .glass()
                updated.title = pickerColumns[column][pickerSelections[column]]
                updated.image = UIImage(systemName: "chevron.up.chevron.down")
                updated.imagePlacement = .trailing
                updated.imagePadding = 6
                pickerButtons[column].configuration = updated
                pickerButtons[column].menu = menuForPickerColumn(column)
            }
        }
        colorWell.selectedColor = [UIColor.systemPink, .systemMint, .systemOrange, .systemIndigo, .systemTeal].randomElement()
        view.tintColor = colorWell.selectedColor
        if switchB.isOn { activity.startAnimating() } else { activity.stopAnimating() }
        ping("Everything shuffled. Delicious chaos.")
    }
}

// MARK: - Result builder for section content

@available(iOS 26.0, *)
@resultBuilder
private enum UIViewBuilder {
    static func buildBlock(_ component: UIView) -> UIView { component }
}

// MARK: - Delegates

@available(iOS 26.0, *)
extension ControlsFidgetDemoViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        ping("Field · done")
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        ping("Text view · \(count) chars")
    }
}
