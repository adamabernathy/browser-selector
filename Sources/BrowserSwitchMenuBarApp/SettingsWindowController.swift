import AppKit
import BrowserSwitchCore
import ServiceManagement

// MARK: - Window Controller

final class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()

    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false)
        window.title = "Browser Switch"
        window.isReleasedWhenClosed = false
        super.init(window: window)

        let tabVC = NSTabViewController()
        tabVC.tabStyle = .toolbar

        let generalVC = GeneralSettingsViewController()
        tabVC.addChild(generalVC)
        tabVC.tabViewItem(for: generalVC)?.label = "General"
        tabVC.tabViewItem(for: generalVC)?.image = NSImage(
            systemSymbolName: "gearshape",
            accessibilityDescription: "General")

        let routerVC = RouterSettingsViewController()
        tabVC.addChild(routerVC)
        tabVC.tabViewItem(for: routerVC)?.label = "Browser Router"
        tabVC.tabViewItem(for: routerVC)?.image = NSImage(
            systemSymbolName: "signpost.right.and.left",
            accessibilityDescription: "Browser Router")

        window.contentViewController = tabVC
        window.center()
    }

    required init?(coder: NSCoder) { nil }

    func show() {
        showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - General Tab

final class GeneralSettingsViewController: NSViewController {
    private var startupCheckbox: NSButton!

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = NSSize(width: 520, height: 80)

        startupCheckbox = NSButton(
            checkboxWithTitle: "Launch Browser Switch at Login",
            target: self,
            action: #selector(toggleStartup(_:)))
        startupCheckbox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startupCheckbox)

        NSLayoutConstraint.activate([
            startupCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startupCheckbox.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        refreshStartupState()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        refreshStartupState()
    }

    private func refreshStartupState() {
        startupCheckbox?.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    @objc private func toggleStartup(_ sender: NSButton) {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Could Not Update Startup Setting"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
        refreshStartupState()
    }
}

// MARK: - Browser Router Tab

final class RouterSettingsViewController: NSViewController {
    private var tableView: NSTableView!
    private var removeButton: NSButton!
    private var bundleCheckboxes: [String: NSButton] = [:]
    private var customRoutes: [BrowserRoute] = []
    private var availableBrowsers: [(bundleID: String, name: String)] = []

    private let patternColID = NSUserInterfaceItemIdentifier("pattern")
    private let browserColID  = NSUserInterfaceItemIdentifier("browser")
    private let profileColID  = NSUserInterfaceItemIdentifier("profile")

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = NSSize(width: 580, height: 460)
        loadAvailableBrowsers()
        buildUI()
        refreshData()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        refreshData()
    }

    // MARK: - Browser discovery

    private func loadAvailableBrowsers() {
        guard let url = URL(string: "https://example.com") else { return }
        availableBrowsers = NSWorkspace.shared.urlsForApplications(toOpen: url)
            .compactMap { appURL -> (String, String)? in
                guard let bid = Bundle(url: appURL)?.bundleIdentifier else { return nil }
                let name = appURL.deletingPathExtension().lastPathComponent
                return (bid, name)
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    // MARK: - UI construction

    private func buildUI() {
        // — URL Bundles section —
        let bundlesHeader = makeSectionLabel("URL Bundles")
        bundlesHeader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bundlesHeader)

        RouteStore.shared.reload()
        let groups = RouteStore.shared.bundleGroups

        var lastTopAnchor: NSLayoutYAxisAnchor = bundlesHeader.bottomAnchor
        for group in groups {
            let enabled = group.routes.allSatisfy(\.isEnabled)
            let targetName = availableBrowsers.first(where: {
                $0.bundleID == group.routes.first?.browserBundleID
            })?.name ?? (group.routes.first?.browserBundleID ?? "")
            let title = "\(group.name)  →  \(targetName)  (\(group.routes.count) routes)"
            let cb = NSButton(checkboxWithTitle: title, target: self, action: #selector(bundleToggled(_:)))
            cb.state = enabled ? .on : .off
            cb.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(cb)
            bundleCheckboxes[group.name] = cb
            NSLayoutConstraint.activate([
                cb.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                cb.topAnchor.constraint(equalTo: lastTopAnchor, constant: 6),
            ])
            lastTopAnchor = cb.bottomAnchor
        }
        let bundlesBottomAnchor = lastTopAnchor

        // — Custom Routes section —
        let routesHeader = makeSectionLabel("Custom Routes")
        routesHeader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(routesHeader)

        // Table
        tableView = NSTableView()
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.rowSizeStyle = .medium
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsEmptySelection = true

        let patternCol = NSTableColumn(identifier: patternColID)
        patternCol.title = "Route or Domain"
        patternCol.width = 230

        let browserCol = NSTableColumn(identifier: browserColID)
        browserCol.title = "Browser"
        browserCol.width = 160

        let profileCol = NSTableColumn(identifier: profileColID)
        profileCol.title = "Profile"
        profileCol.width = 120

        tableView.addTableColumn(patternCol)
        tableView.addTableColumn(browserCol)
        tableView.addTableColumn(profileCol)

        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .bezelBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // + / - buttons
        let addBtn = NSButton(title: "", target: self, action: #selector(addRoute))
        addBtn.image = NSImage(systemSymbolName: "plus", accessibilityDescription: "Add route")
        addBtn.bezelStyle = .smallSquare
        addBtn.translatesAutoresizingMaskIntoConstraints = false

        removeButton = NSButton(title: "", target: self, action: #selector(removeRoute))
        removeButton.image = NSImage(systemSymbolName: "minus", accessibilityDescription: "Remove route")
        removeButton.bezelStyle = .smallSquare
        removeButton.isEnabled = false
        removeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(addBtn)
        view.addSubview(removeButton)

        NSLayoutConstraint.activate([
            bundlesHeader.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            bundlesHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bundlesHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            routesHeader.topAnchor.constraint(equalTo: bundlesBottomAnchor, constant: 16),
            routesHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            routesHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            scrollView.topAnchor.constraint(equalTo: routesHeader.bottomAnchor, constant: 6),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: addBtn.topAnchor, constant: -4),

            addBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            addBtn.widthAnchor.constraint(equalToConstant: 24),
            addBtn.heightAnchor.constraint(equalToConstant: 22),

            removeButton.leadingAnchor.constraint(equalTo: addBtn.trailingAnchor, constant: 1),
            removeButton.centerYAnchor.constraint(equalTo: addBtn.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 24),
            removeButton.heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    private func makeSectionLabel(_ title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: NSFont.smallSystemFontSize, weight: .semibold)
        label.textColor = .secondaryLabelColor
        return label
    }

    // MARK: - Data

    private func refreshData() {
        RouteStore.shared.reload()
        customRoutes = RouteStore.shared.routes.filter { !$0.isBuiltIn }
        tableView?.reloadData()
        updateBundleCheckboxStates()
        updateRemoveButton()
    }

    private func updateBundleCheckboxStates() {
        for (groupName, cb) in bundleCheckboxes {
            let groupRoutes = RouteStore.shared.routes.filter { $0.bundleGroupName == groupName }
            cb.state = groupRoutes.allSatisfy(\.isEnabled) ? .on : .off
        }
    }

    private func updateRemoveButton() {
        removeButton?.isEnabled = (tableView?.selectedRow ?? -1) >= 0
    }

    // MARK: - Actions

    @objc private func bundleToggled(_ sender: NSButton) {
        guard let groupName = bundleCheckboxes.first(where: { $0.value === sender })?.key else { return }
        RouteStore.shared.setGroupEnabled(groupName, enabled: sender.state == .on)
    }

    @objc private func addRoute() {
        let firstBrowser = availableBrowsers.first?.bundleID ?? "com.apple.Safari"
        let route = BrowserRoute(pattern: "", browserBundleID: firstBrowser)
        RouteStore.shared.add(route)
        customRoutes = RouteStore.shared.routes.filter { !$0.isBuiltIn }
        tableView.reloadData()
        let newRow = customRoutes.count - 1
        tableView.selectRowIndexes(IndexSet(integer: newRow), byExtendingSelection: false)
        tableView.scrollRowToVisible(newRow)
        tableView.editColumn(0, row: newRow, with: nil, select: true)
    }

    @objc private func removeRoute() {
        let row = tableView.selectedRow
        guard row >= 0, row < customRoutes.count else { return }
        RouteStore.shared.remove(id: customRoutes[row].id)
        refreshData()
    }
}

// MARK: - NSTableViewDataSource

extension RouterSettingsViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        customRoutes.count
    }
}

// MARK: - NSTableViewDelegate

extension RouterSettingsViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let route = customRoutes[row]

        switch tableColumn?.identifier {
        case patternColID:
            let id = NSUserInterfaceItemIdentifier("patternCell")
            let cell = tableView.makeView(withIdentifier: id, owner: self) as? PatternCellView
                ?? PatternCellView(identifier: id, delegate: self)
            cell.textField?.stringValue = route.pattern
            cell.textField?.placeholderString = "e.g. *.work.com"
            cell.rowIndex = row
            return cell

        case browserColID:
            let id = NSUserInterfaceItemIdentifier("browserCell")
            let cell = tableView.makeView(withIdentifier: id, owner: self) as? BrowserCellView
                ?? BrowserCellView(identifier: id, target: self, action: #selector(browserChanged(_:)))
            cell.configure(browsers: availableBrowsers, selectedBundleID: route.browserBundleID, row: row)
            return cell

        case profileColID:
            let id = NSUserInterfaceItemIdentifier("profileCell")
            let cell = tableView.makeView(withIdentifier: id, owner: self) as? NSTableCellView
                ?? makeDisabledCell(identifier: id)
            cell.textField?.stringValue = route.profile ?? ""
            cell.textField?.placeholderString = "Coming soon"
            return cell

        default:
            return nil
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        updateRemoveButton()
    }

    private func makeDisabledCell(identifier: NSUserInterfaceItemIdentifier) -> NSTableCellView {
        let cell = NSTableCellView()
        cell.identifier = identifier
        let field = NSTextField()
        field.isEditable = false
        field.isBordered = false
        field.drawsBackground = false
        field.isEnabled = false
        field.font = .systemFont(ofSize: NSFont.systemFontSize)
        field.textColor = .tertiaryLabelColor
        field.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(field)
        cell.textField = field
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 4),
            field.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -4),
            field.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        ])
        return cell
    }

    @objc private func browserChanged(_ sender: NSPopUpButton) {
        let row = sender.tag
        guard row >= 0, row < customRoutes.count,
              let bundleID = sender.selectedItem?.representedObject as? String else { return }
        var route = customRoutes[row]
        route.browserBundleID = bundleID
        customRoutes[row] = route
        RouteStore.shared.update(route)
    }
}

// MARK: - Pattern text field delegate

extension RouterSettingsViewController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let cell = obj.object as? RoutingTextField else { return }
        let row = cell.rowIndex
        guard row >= 0, row < customRoutes.count else { return }
        var route = customRoutes[row]
        route.pattern = cell.stringValue.trimmingCharacters(in: .whitespaces)
        customRoutes[row] = route
        RouteStore.shared.update(route)
    }
}

// MARK: - Cell views

/// NSTextField that carries its table row index
final class RoutingTextField: NSTextField {
    var rowIndex: Int = -1
}

/// NSTableCellView containing an editable pattern text field
final class PatternCellView: NSTableCellView {
    var rowIndex: Int {
        get { (textField as? RoutingTextField)?.rowIndex ?? -1 }
        set { (textField as? RoutingTextField)?.rowIndex = newValue }
    }

    init(identifier: NSUserInterfaceItemIdentifier, delegate: NSTextFieldDelegate) {
        super.init(frame: .zero)
        self.identifier = identifier
        let field = RoutingTextField()
        field.isEditable = true
        field.isBordered = false
        field.drawsBackground = false
        field.font = .systemFont(ofSize: NSFont.systemFontSize)
        field.delegate = delegate
        field.translatesAutoresizingMaskIntoConstraints = false
        addSubview(field)
        textField = field
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            field.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            field.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }
}

/// NSView containing an NSPopUpButton for browser selection
final class BrowserCellView: NSView {
    let popup = NSPopUpButton(frame: .zero, pullsDown: false)

    init(identifier: NSUserInterfaceItemIdentifier, target: AnyObject?, action: Selector) {
        super.init(frame: .zero)
        self.identifier = identifier
        popup.target = target
        popup.action = action
        popup.translatesAutoresizingMaskIntoConstraints = false
        addSubview(popup)
        NSLayoutConstraint.activate([
            popup.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            popup.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            popup.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { nil }

    func configure(browsers: [(bundleID: String, name: String)], selectedBundleID: String, row: Int) {
        popup.tag = row
        popup.removeAllItems()
        for browser in browsers {
            popup.addItem(withTitle: browser.name)
            popup.lastItem?.representedObject = browser.bundleID
        }
        if let idx = browsers.firstIndex(where: { $0.bundleID == selectedBundleID }) {
            popup.selectItem(at: idx)
        }
    }
}
