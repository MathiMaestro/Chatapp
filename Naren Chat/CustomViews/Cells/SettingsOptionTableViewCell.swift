//
//  SettingsOptionTableViewCell.swift
//  Naren Chat
//
//  Created by Mathiyalagan S on 02/10/22.
//

import UIKit


class SettingsOptionTableViewCell : UITableViewCell {
    
    static let reusableId = "SettingsOptionTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    func configureView() {
        accessoryType   = .disclosureIndicator
        selectionStyle  = .none
    }
    
    func updateData(for type: SettingsOptions) {
        textLabel?.text = type.rawValue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
