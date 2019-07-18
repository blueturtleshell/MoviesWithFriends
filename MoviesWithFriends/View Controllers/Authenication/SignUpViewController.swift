//
//  SignUpViewController.swift
//  KonomuV
//
//  Created by Peter Sun on 7/1/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    let signUpView: SignUpView = {
        let signUpView = SignUpView()
        return signUpView
    }()

    private var profileImage: UIImage?

    private let db = Firestore.firestore()

    override func loadView() {
        view = signUpView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)

        signUpView.textFields.forEach {
            $0.delegate = self
            $0.addTarget(self, action: #selector(textEditingChanged), for: .editingChanged)
        }

        signUpView.avatarButton.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
        signUpView.registerButton.addTarget(self, action: #selector(handleUserRegistration), for: .touchUpInside)
        signUpView.loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)

        signUpView.registerButton.isEnabled = false
        configureRegisterButton()
    }

    @objc func adjustForKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        guard let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
                self.view.transform = .identity
            })
        } else {
            let bottomSpace = view.frame.height - signUpView.stackView.frame.origin.y - signUpView.stackView.frame.height
            let padding: CGFloat = 8
            let difference = keyboardViewEndFrame.height - bottomSpace + padding
            self.view.transform = CGAffineTransform(translationX: 0, y: -difference) // negative goes up / positive down
        }
    }

    @objc func textEditingChanged(_ textField: UITextField) {
        signUpView.registerButton.isEnabled = signUpView.textFields.allSatisfy { !$0.text!.isEmpty }
        configureRegisterButton()
    }

    @objc func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func handleUserRegistration() {
        let userName = signUpView.userNameTextField.text!
        let fullName = signUpView.fullNameTextField.text!
        let email = signUpView.emailTextField.text!.lowercased()
        let emailConfirm = signUpView.confirmEmailTextField.text!.lowercased()
        let password = signUpView.passwordTextField.text!
        let passwordConfirm = signUpView.confirmPasswordTextField.text!

        guard email == emailConfirm && password == passwordConfirm else {
            print("Missmatch")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { initialAuthResult, error in
            if let error = error {
                print(error)
                return
            } else if let authResult = initialAuthResult {
                let userID = authResult.user.uid
                var profileImageURL: URL? = nil

                if let profileImage = self.profileImage, let imageData = profileImage.pngData() {
                    self.uploadImage(imageData: imageData) { uploadResult in
                        switch uploadResult {
                        case .success(let imageURL):
                            profileImageURL = imageURL
                        case .failure(let error):
                            print(error)
                            return
                        }
                    }
                }
                self.updateUserData(id: userID, userName: userName, fullName: fullName, imageURL: profileImageURL, completion: { error in
                    if let error = error {
                        print(error)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }

    private func updateUserData(id: String, userName: String, fullName: String?, imageURL: URL?, completion: @escaping (Error?) -> Void) {
        let userDict: [String: Any] = ["id": id, "user_name": userName,
                                       "full_name": fullName ?? "", "profile_url": imageURL?.absoluteString ?? ""]
        db.document("users/\(id)").setData(userDict) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    private func uploadImage(imageData: Data, completion: @escaping (Result<URL?, Error>) -> Void) {
        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        storageRef.putData(imageData, metadata: nil, completion: { (_, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(url))
            })
        })
    }

    private func showError(text: String, error: Error? = nil) {
    }

    @objc func loginButtonPressed() {
        navigationController?.popViewController(animated: true)
    }

    private func configureRegisterButton() {
        if signUpView.registerButton.isEnabled {
            signUpView.registerButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        } else {
            signUpView.registerButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
}

extension SignUpViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        profileImage = image
        signUpView.avatarButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)

        dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
