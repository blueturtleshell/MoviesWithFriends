//
//  AuthenticationViewController.swift
//  KonomuV
//
//  Created by Peter Sun on 7/1/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//


import UIKit
import Firebase

class LoginViewController: UIViewController {

    let loginView: LoginView = {
        let loginView = LoginView()
        return loginView
    }()

    override func loadView() {
        view = loginView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        navigationController?.isNavigationBarHidden = true
        loginView.loginButton.isEnabled = false
        configureRegisterButton()

        loginView.dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        loginView.signUpButton.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)
        loginView.loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
    }

    @objc private func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }

    @objc func loginButtonPressed() {
        guard Auth.auth().currentUser == nil else { return }

        let email = loginView.emailTextField.text!
        let password = loginView.passwordTextField.text!

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error)
                //FIXME: display prompt
            } else if let _ = authResult {
                NotificationCenter.default.post(name: .userDidLogin, object: nil, userInfo: nil)
                self.tabBarController?.selectedIndex = 1 // FIXME: change index if view controllers added
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc func signUpButtonPressed() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }

    @objc func textEditingChanged(_ textField: UITextField) {
        loginView.loginButton.isEnabled = [loginView.emailTextField, loginView.passwordTextField].allSatisfy { !$0.text!.isEmpty }
        configureRegisterButton()
    }

    private func configureRegisterButton() {
        if loginView.loginButton.isEnabled {
            loginView.loginButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        } else {
            loginView.loginButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
