//
//  ChatAnimationSettings.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 26.01.2021.
//

import UIKit

private extension TimingModelName {
    static func sort(arr: [TimingModelName]) -> [TimingModelName] {
        let order: [TimingModelName] = [/*.background, */.xPos, .yPos, .bubbleShape, .textPosition, .colorChange, .timeAppears, .scale]
        
        var orderDict: [TimingModelName: Int] = [:]
        for (idx, name) in order.enumerated() {
            orderDict[name] = idx
        }
        
        return arr.sorted { (n1, n2) -> Bool in
            let i1 = orderDict[n1] ?? 999
            let i2 = orderDict[n2] ?? 999
            return i1 < i2
        }
    }
    
    func displayName(key: ChatAnimationSettingsModel.MessagesKey) -> String {
        switch (self, key) {
        case (.background, _):   return "Gradient Position"
        case (.xPos, _):         return "X Position"
        case (.yPos, _):         return "Y Position"
        case (.bubbleShape, _):  return "Bubble Shape"
        case (.textPosition, _): return "Text Position"
        case (.colorChange, _):  return "Color Change"
        case (.timeAppears, _):  return "Time Appears"
        case (.scale, .singleEmoji):return "Emoji Scale"
        case (.scale, .sticker):return "Sticker Scale"
        case (.scale, .videoMessage):return "Scale"
        case (.scale, .voiceMessage):return "Scale"
        default:            return ""
        }
    }
}

class ChatAnimationSettings: UITableViewController {
    
    var settings: ChatAnimationSettingsModel!
    var settingsKey: ChatAnimationSettingsModel.MessagesKey = .background
    var timingKeys: [TimingModelName] = [.background]
    weak var lastBgCell: BackgroundCell?
    
    // MARK: - VC
    
    static func displayFrom(vc: UIViewController) {
        let selfVc = UIStoryboard(name: "ChatAnimationSettings", bundle: Bundle(for: self)).instantiateViewController(withIdentifier: "settings_nav")
        vc.present(selfVc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dissmiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItem.Style.done, target: self, action: #selector(dissmiss))
        navigationItem.title = "Animation Settings"
        
        settings = ChatAnimationSettingsModel()
    }
    
    @objc func dissmiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func applyAndDissmissVC() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }
    
    func update(time: TimingTime) {
        settings.messages[settingsKey]?.update(duration: time)
        var visible = tableView.indexPathsForVisibleRows ?? []
        if case .background = settingsKey {
            visible = visible.filter({$0.section == 1})
        } else {
            visible = visible.filter({$0.section >= 1})
        }
        visible.append(IndexPath(row: 1, section: 0))
        tableView.reloadRows(at: visible, with: .fade)
    }
    
    func update(type: ChatAnimationSettingsModel.MessagesKey) {
        settingsKey = type
        let timings = settings.messages[type]?.timing ?? [:]
        timingKeys = Array(timings.keys)
        timingKeys = TimingModelName.sort(arr: timingKeys)
        tableView.reloadData()
    }
}

// MARK: - Actions
private extension ChatAnimationSettings {
    func actionSelectType() {
        let vc = ChatAnimationTypeSelection(style: .grouped)
        vc.settings = settings
        vc.onSelect = {[weak self] newType in
            self?.update(type: newType)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    func actionSelectTime() {
        let alert = UIAlertController(title: nil, message: "Duration", preferredStyle: .actionSheet)
        for t in TimingTime.allCases {
            alert.addAction(UIAlertAction(title: t.display(), style: .default, handler: {[weak self] (_) in
                self?.update(time: t)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func actionShareParametrs() {
        
    }
    func actionImportParameters() {
        
    }
    func actionRestoreParametrs() {
        
    }
}

// MARK: - Table
extension ChatAnimationSettings {
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch settingsKey {
        case .background:
            return 4
        default:
            return 1 + settings.messages[settingsKey]!.timing.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (settingsKey, section) {
        case (_, 0): return 5
        case (.background, 3): return settings.backgroundColors.count
        default: return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (settingsKey, section) {
        case (_, 0): return nil
        case (.background, 2): return "Background Preview"
        case (.background, 3): return "Colors"
        default: return timingKeys[section - 1].displayName(key: settingsKey)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (settingsKey, indexPath.section) {
        case (_, 0), (.background, 3): return 46 // simple cell
        case (.background, 2): return 260 // background preview
        default: return 290 // timing control
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // actions cells
        if indexPath.section == 0 {
            let action = CellAction.init(rawValue: indexPath.row)!
            return cellFor(action: action, tableView: tableView, indexPath: indexPath)
        }
        
        switch (settingsKey, indexPath.section) {
        case (.background, 2):
            return cellForBackground(tableView: tableView, indexPath: indexPath)
        case (.background, 3):
            return cellForColor(tableView: tableView, indexPath: indexPath)
        default:
            let timingKey = timingKeys[indexPath.section - 1]
            return cellFor(timingKey: timingKey, tableView: tableView, indexPath: indexPath)
        }
    }
    
    func cellForColor(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "color_cell", for: indexPath) as? ColorSelectionCell else {
            return UITableViewCell()
        }
        
        let hexColor = settings.backgroundColors[indexPath.row]
        let color = UIColor(hex: hexColor) ?? .white
        cell.setup(name: "Color \(indexPath.row+1)", color: color)
        return cell
    }
    
    func cellForBackground(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "background_cell", for: indexPath) as? BackgroundCell else {
            return UITableViewCell()
        }
        
        lastBgCell = cell
        let colors = settings.backgroundColors.map({UIColor(hex: $0) ?? UIColor.white })
        print(cell.display)
        cell.display.colors = colors
        return cell
    }
    
    func cellFor(timingKey: TimingModelName, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "timing_cell", for: indexPath) as? TimingCell else {
            return UITableViewCell()
        }
        
        let timing = settings.messages[settingsKey]!.timing[timingKey]!
        cell.setup(name: timingKey, timing: timing)
        cell.timingView.onChange = {[weak self] model in
            self?.settings.messages[self!.settingsKey]?.timing[timingKey] = model
        }
        return cell
    }
    
    enum CellAction: Int {
        case type = 0, duration, share, importParams, restore
    }
    func cellFor(action: CellAction, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ActionCell
        switch action {
        case .type, .duration:
            cell = tableView.dequeueReusableCell(withIdentifier: "option_cell", for: indexPath) as! ActionCell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "action_cell", for: indexPath) as! ActionCell
        }
        
        
        switch action {
        case .type:
            cell.setup(name: "Animation Type",
                       detail: settings.messages[settingsKey]?.shortName,
                       action: { [weak self] in self?.actionSelectType() })
        case .duration:
            let time = settings.messages[settingsKey]?.timing.first?.value.durationF
            let detail = TimingTime.fromFloat(time).display()
            cell.setup(name: "Duration",
                       detail: detail,
                       action: { [weak self] in self?.actionSelectTime() })
        case .share:
            cell.setup(name: "Share Parameters",
                       color: .systemBlue,
                       action: { [weak self] in self?.actionShareParametrs() })
        case .importParams:
            cell.setup(name: "Import Parameters",
                       color: .systemBlue,
                       action: { [weak self] in self?.actionImportParameters() })
        case .restore:
            cell.setup(name: "Restore to Default",
                       color: .systemRed,
                       action: { [weak self] in self?.actionRestoreParametrs() })
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? ActionCell {
            cell.action?()
        }
    }
}