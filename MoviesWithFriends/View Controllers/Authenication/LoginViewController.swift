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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupView() {
        navigationController?.isNavigationBarHidden = true
        loginView.loginButton.isEnabled = false
        configureRegisterButton()

        let tapToDismissTextFieldGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        loginView.addGestureRecognizer(tapToDismissTextFieldGesture)

        loginView.dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        loginView.signUpButton.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)
        loginView.loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)

        loginView.textFields.forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textEditingChanged), for: .editingChanged)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }

    @objc func loginButtonPressed() {
        guard Auth.auth().currentUser == nil else { return }

        let email = loginView.emailTextField.text!
        let password = loginView.passwordTextField.text!

        let logInHud = HUDView.hud(inView: self.loginView, animated: true)
        logInHud.accessoryType = .activityIndicator
        logInHud.text = "Please wait"

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                logInHud.remove(from: self.loginView)
                self.loginView.errorMessageLabel.text = error.localizedDescription

                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    self.loginView.errorMessageLabel.text = nil
                })

            } else if let _ = authResult {
                logInHud.remove(from: self.loginView)
                NotificationCenter.default.post(name: .userDidLogin, object: nil, userInfo: nil)
            }
        }
    }

    @objc func signUpButtonPressed() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }

    @objc func textEditingChanged(_ textField: UITextField) {
        loginView.loginButton.isEnabled = loginView.textFields.allSatisfy { !$0.text!.isEmpty }
        configureRegisterButton()
    }

    private func configureRegisterButton() {
        if loginView.loginButton.isEnabled {
            loginView.loginButton.setTitleColor(.black, for: .normal)
            loginView.loginButton.backgroundColor = UIColor(named: "offYellow")
        } else {
            loginView.loginButton.setTitleColor(.lightGray, for: .normal)
            loginView.loginButton.backgroundColor = #colorLiteral(red: 0.1869646256, green: 0.1869646256, blue: 0.1869646256, alpha: 1)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
