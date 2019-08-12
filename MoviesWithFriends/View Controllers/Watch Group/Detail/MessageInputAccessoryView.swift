//
//  MessageInputAccessoryView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/7/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class MessageInputAccessoryView: UIView, UITextViewDelegate {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var canResignFirstResponder: Bool {
        return true
    }

    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 4
        textView.layer.borderWidth = 0.5
        textView.font = .systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        return textView
    }()

    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        return button
    }()

    let textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/100"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight

        addSubview(messageTextView)
        addSubview(textCountLabel)
        addSubview(sendButton)

        messageTextView.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(6)
            make.right.equalTo(sendButton.snp.left).inset(-12)
        }

        textCountLabel.snp.makeConstraints { make in
            make.top.equalTo(messageTextView)
            make.centerX.equalTo(sendButton)
        }

        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(6)
            make.size.equalTo(CGSize(width: 44, height: 22))
            make.bottom.equalToSuperview().inset(6)
        }

        messageTextView.delegate = self
        messageTextView.isScrollEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let textSize = messageTextView.sizeThatFits(CGSize(width: messageTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: self.bounds.width, height: textSize.height + 12)
    }
}
