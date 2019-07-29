//
//  WatchGroupView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/26/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

protocol CreateGroupViewDelegate: class {
    func toggleDatePicker(isVisible: Bool)
}

class WatchGroupView: UIView {

    let container: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    let createWatchGroupLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Watch Group"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let messageLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    let movieNameLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.numberOfLines = 1
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    let groupNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Group Name"
        textField.borderStyle = .roundedRect
        return textField
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "When"
        label.textColor = .white
        return label
    }()

    let dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set Date", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.setValue(UIColor.white, forKey: "textColor")
        return datePicker
    }()

    let friendLabel: UILabel = {
        let label = UILabel()
        label.text = "Friends"
        label.textColor = .white
        return label
    }()

    let friendCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/0"
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()

    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()

    let friendsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
        return tableView
    }()
    

    weak var delegate: CreateGroupViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        addSubview(container)
        container.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(createWatchGroupLabel)
        contentView.addSubview(messageLabelContainer)
        messageLabelContainer.addSubview(messageLabel)
        contentView.addSubview(movieNameLabel)
        contentView.addSubview(groupNameTextField)
        contentView.addSubview(dateLabel)
        contentView.addSubview(dateButton)
        contentView.addSubview(datePicker)
        contentView.addSubview(friendLabel)
        contentView.addSubview(friendCountLabel)
        contentView.addSubview(dividerView)
        contentView.addSubview(friendsTableView)

        container.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        scrollView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.edges.equalToSuperview()
        }

        createWatchGroupLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }

        messageLabelContainer.snp.makeConstraints { make in
            make.top.equalTo(createWatchGroupLabel.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        movieNameLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabelContainer.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        groupNameTextField.snp.makeConstraints { make in
            make.top.equalTo(movieNameLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
            make.height.equalTo(44)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(groupNameTextField.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
        }

        dateButton.snp.makeConstraints { make in
            make.firstBaseline.equalTo(dateLabel)
            make.right.equalToSuperview().inset(12)
            make.width.equalTo(150)
        }

        datePicker.snp.makeConstraints { make in
            make.top.equalTo(dateLabel).offset(24)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
            make.height.equalTo(0)
        }

        friendLabel.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(36)
            make.left.equalToSuperview().offset(12)
        }

        friendCountLabel.snp.makeConstraints { make in
            make.top.equalTo(friendLabel)
            make.right.equalToSuperview().inset(12)
            make.width.equalTo(60)
        }

        dividerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(friendLabel.snp.bottom).offset(6)
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        friendsTableView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.height.equalTo(800)
        }

        dateButton.addTarget(self, action: #selector(toggleDatePicker), for: .touchUpInside)

    }

    fileprivate var isDatePickerVisible = false

    @objc private func toggleDatePicker() {
        isDatePickerVisible.toggle()

        let height = isDatePickerVisible ? 240 : 0

        UIView.animate(withDuration: 0.4) {
            self.datePicker.isHidden = !self.isDatePickerVisible
            self.datePicker.snp.updateConstraints({ make in
                make.top.equalTo(self.dateLabel).offset(24)
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview().inset(12)
                make.height.equalTo(height)
            })
            self.layoutIfNeeded()
        }
        delegate?.toggleDatePicker(isVisible: isDatePickerVisible)
    }
}
