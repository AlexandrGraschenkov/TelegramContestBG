//
//  ChatAnimationTypeSelection.swift
//  TelegramContestBG
//
//  Created by Alexander Graschenkov on 28.01.2021.
//

import UIKit

class ChatAnimationTypeSelection: UITableViewController {

    typealias AnimType = ChatAnimationSettingsModel.MessagesKey
    var settings: ChatAnimationSettingsModel?
    var displayTypes: [(name: String, types: [AnimType])] = []
    var onSelect: ((AnimType)->())?
    override func viewDidLoad() {
        super.viewDidLoad()

        let messages: [AnimType] = [.smallMessage, .bigMessage, .linkPreview, .singleEmoji, .sticker, .voiceMessage, .videoMessage]
        displayTypes = [("Messages", messages), ("Other", [.background])]
        
        navigationItem.title = "Animation Type"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func animType(forIndex indexPath: IndexPath) -> AnimType {
        return displayTypes[indexPath.section].types[indexPath.row]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return displayTypes.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayTypes[section].types.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return displayTypes[section].name
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let type = animType(forIndex: indexPath)
        cell.textLabel?.text = settings?.messages[type]?.fullName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        super.tableView(tableView, didSelectRowAt: indexPath)
        onSelect?(animType(forIndex: indexPath))
        navigationController?.popViewController(animated: true)
    }

}
