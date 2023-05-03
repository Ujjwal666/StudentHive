//
//  SignupViewController.swift
//  RoomBook
//
//  Created by Sanjaya Subedi on 3/22/23.
//

import UIKit
import ParseSwift
class SignupViewController: UIViewController {

    @IBOutlet weak var setEmail: UITextField!
    
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var verifyPassword: UITextField!
    @IBOutlet weak var setPassword: UITextField!
    @IBOutlet weak var studentID: UITextField!
    @IBOutlet weak var verifyEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func didTapSignup(sender: UIButton){
            
            guard let username = setEmail.text,
                  let email = verifyEmail.text,
                  let stdId = studentID.text,
                  let password = setPassword.text,
                  !username.isEmpty,
                  !stdId.isEmpty,
                  !password.isEmpty else {

                showMissingFieldsAlert()
                return
            }
            

       
            
            var newUser = User()
            newUser.username = username
            newUser.email = email
            newUser.studentID = stdId
            newUser.password = password
            newUser.signup { [weak self] result in

                switch result {
                case .success(let user):

                    print("✅ Successfully signed up user \(user)")

                    // Post a notification that the user has successfully signed up.
                    NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextVC = storyBoard.instantiateViewController(withIdentifier: "UITabBarController") as! UITabBarController
                    self?.navigationController?.pushViewController(nextVC, animated: true)
                    self?.navigationItem.hidesBackButton = true 

                case .failure(let error):
                    // Failed sign up
                    self?.showAlert(description: error.localizedDescription)
                }
            }

        }

        private func showAlert(description: String?) {
            let alertController = UIAlertController(title: "Unable to Sign Up", message: description ?? "Unknown error", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            present(alertController, animated: true)
        }

        private func showMissingFieldsAlert() {
            let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to sign you up.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            present(alertController, animated: true)
        }
    

 

}
