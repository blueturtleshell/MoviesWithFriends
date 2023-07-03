//
//  FriendCodeViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class FriendCodeViewController: UIViewController {

    let friendCodeView: FriendCodeView = {
        return FriendCodeView()
    }()

    private let user: MWFUser

    init(user: MWFUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = friendCodeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        configureView()
    }

    private func setupView() {
        friendCodeView.copyButton.addTarget(self, action: #selector(copyFriendCode), for: .touchUpInside)
    }

    private func configureView() {
        navigationItem.title = "Friend Code"
        friendCodeView.friendCodeLabel.text = user.friendCode
        friendCodeView.qrCodeImageView.image = generateQRCode(from: user.friendCode)
    }

    @objc private func copyFriendCode() {
        let clipboard = UIPasteboard.general
        clipboard.string = user.friendCode

        self.friendCodeView.copyButton.setTitle("Copied", for: .normal)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.friendCodeView.copyButton.setTitle("Copy to Clipboard", for: .normal)
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}
