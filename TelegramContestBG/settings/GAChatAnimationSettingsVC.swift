//
//  ChatAnimationSettings.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 26.01.2021.
//

import UIKit

private extension GAAnimElemName {
    static func sort(arr: [GAAnimElemName]) -> [GAAnimElemName] {
        let order: [GAAnimElemName] = [/*.background, */.xPos, .yPos, .bubbleShape, .textPosition, .colorChange, .timeAppears, .scale]
        
        var orderDict: [GAAnimElemName: Int] = [:]
        for (idx, name) in order.enumerated() {
            orderDict[name] = idx
        }
        
        return arr.sorted { (n1, n2) -> Bool in
            let i1 = orderDict[n1] ?? 999
            let i2 = orderDict[n2] ?? 999
            return i1 < i2
        }
    }
    
    func displayName(key: GAChatAnimModel.ObjectKey) -> String {
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

class GAChatAnimationSettingsVC: UITableViewController {
    
    var settings: GAChatAnimModel!
    var settingsKey: GAChatAnimModel.ObjectKey = .background
    var timingKeys: [GAAnimElemName] = [.background]
    weak var lastBgCell: GABackgroundCell?
    
    // MARK: - VC
    
    static func displayFrom(vc: UIViewController) {
        let selfVc = UIStoryboard(name: "ChatAnimationSettings", bundle: Bundle(for: self)).instantiateViewController(withIdentifier: "settings_nav")
        vc.present(selfVc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dissmiss))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItem.Style.done, target: self, action: #selector(apply))
        navigationItem.title = "Animation Settings"
        
        settings = GAChatAnimModel.fromDefaults()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    
    @objc func onTap() {
        view.endEditing(true)
    }
    
    @objc func dissmiss() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func apply() {
        settings.saveToDefaults()
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
        settings.objects[settingsKey]?.update(duration: time)
        var visible = tableView.indexPathsForVisibleRows ?? []
        if case .background = settingsKey {
            visible = visible.filter({$0.section == 1})
        } else {
            visible = visible.filter({$0.section >= 1})
        }
        visible.append(IndexPath(row: 1, section: 0))
        tableView.reloadRows(at: visible, with: .fade)
    }
    
    func update(type: GAChatAnimModel.ObjectKey) {
        settingsKey = type
        let timings = settings.objects[type]?.timing ?? [:]
        timingKeys = Array(timings.keys)
        timingKeys = GAAnimElemName.sort(arr: timingKeys)
        tableView.reloadData()
    }
}

// MARK: - Actions
private extension GAChatAnimationSettingsVC {
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
        guard let urlPath = settings.saveToDocuments() else {
            return
        }
        
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
//        alert.addActivityIndicator()
//        present(alert, animated: true, completion: nil)
        let vc = UIActivityViewController(activityItems: [urlPath], applicationActivities: nil)
        present(vc, animated: true, completion: {
//            alert.dismiss(animated: true, completion: nil)
        })
    }
    func actionImportParameters() {
        let documentsPicker = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .open)
        documentsPicker.delegate = self
//        documentsPicker.modalPresentationStyle = .fullScreen
        present(documentsPicker, animated: true, completion: nil)
    }
    func actionRestoreParametrs() {
        settings = GAChatAnimModel()
        tableView.reloadData()
    }
    
    func openBackgroundExample() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier:  "background_vc") as? ChatBackgroundController else {
            return
        }
        
        vc.settings = settings
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension GAChatAnimationSettingsVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if let err = settings.loadFrom(url: url) {
            let alert = UIAlertController(title: "Can't import settings", message: err.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            print("Success loaded")
            tableView.reloadData()
        }
    }
}

// MARK: - Table
extension GAChatAnimationSettingsVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch settingsKey {
        case .background:
            return 4
        default:
            return 1 + settings.objects[settingsKey]!.timing.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (settingsKey, section) {
        case (_, 0): return 5
        case (.background, 3): return settings.backgroundColorsHex.count
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "color_cell", for: indexPath) as? GAColorSelectionCell else {
            return UITableViewCell()
        }
        
        let hexColor = settings.backgroundColorsHex[indexPath.row]
        let color = UIColor(hex: hexColor) ?? .white
        cell.setup(name: "Color \(indexPath.row+1)", color: color)
        cell.colorView.onChange = { [weak self] color in
            guard let `self` = self else { return }
            self.settings.backgroundColorsHex[indexPath.row] = color.hex()
            self.lastBgCell?.displayView.colors = self.settings.backgroundColors
        }
        return cell
    }
    
    func cellForBackground(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "background_cell", for: indexPath) as? GABackgroundCell else {
            return UITableViewCell()
        }
        
        lastBgCell = cell
        cell.displayView.colors = settings.backgroundColors
        cell.openPressed = {[weak self] in
            self?.openBackgroundExample()
        }
        return cell
    }
    
    func cellFor(timingKey: GAAnimElemName, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "timing_cell", for: indexPath) as? GATimingCell else {
            return UITableViewCell()
        }
        
        let timing = settings.objects[settingsKey]!.timing[timingKey]!
        cell.setup(name: timingKey, timing: timing)
        cell.timingView.onChange = {[weak self] model in
            guard let `self` = self else { return }
            self.settings.objects[self.settingsKey]?.timing[timingKey] = model
            if case .background = self.settingsKey {
                self.lastBgCell?.displayView.timing = model
            }
        }
        return cell
    }
    
    enum CellAction: Int {
        case type = 0, duration, share, importParams, restore
    }
    func cellFor(action: CellAction, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell: GAActionCell
        switch action {
        case .type, .duration:
            cell = tableView.dequeueReusableCell(withIdentifier: "option_cell", for: indexPath) as! GAActionCell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "action_cell", for: indexPath) as! GAActionCell
        }
        
        
        switch action {
        case .type:
            cell.setup(name: "Animation Type",
                       detail: settings.objects[settingsKey]?.shortName,
                       action: { [weak self] in self?.actionSelectType() })
        case .duration:
            let time = settings.objects[settingsKey]?.timing.first?.value.durationF
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
        
        if let cell = tableView.cellForRow(at: indexPath) as? GAActionCell {
            cell.action?()
        }
    }
}
