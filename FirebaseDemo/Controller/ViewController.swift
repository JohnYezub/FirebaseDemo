//
//  ViewController.swift
//  FirebaseDemo
//
//  Created by   admin on 07/07/20.
//  Copyright © 2020 Evgeny Ezub. All rights reserved.
//

import UIKit
import  Firebase

import AppCenter
import AppCenterCrashes


class ViewController: UIViewController {
    
    @IBOutlet weak var warnText: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MSAppCenter.start("973c0f51-b13b-4766-8923-3c70865e2b17", withServices:[
          MSCrashes.self
        ])
        
        warnText.alpha = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        ref = Database.database().reference(withPath: "users")
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
            }
        }
        
    }
    
    func displayWarningLabel(withText text: String) {
        warnText.text = text
        UIView.animate(withDuration: 2, delay: 0, options: .curveLinear, animations: {
            self.warnText.alpha = 1
        }) {  [weak self]  (comlete) in
            self?.warnText.alpha = 0
        }
    }
    
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(withText: "Email or password is incorrect")
            return }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if error != nil {
                self?.displayWarningLabel(withText: "Login failed, try to register"); return
            }
            if result != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                self?.emailTextField.text = ""
                self?.passwordTextField.text = ""
                return
            }
            self?.displayWarningLabel(withText: "No user exist")
        }
    }
    
    @IBAction func register(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else
        {
            displayWarningLabel(withText: "Info is incorrect")
            return
            
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard error == nil, result != nil else {
                self?.displayWarningLabel(withText: "Failed. \(error!.localizedDescription)")
                return }
            //self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
            self?.emailTextField.text = ""
            self?.passwordTextField.text = ""
            let userRef = self?.ref.child((result?.user.uid)!)
            userRef?.setValue(["email": result?.user.email])
        }
    }
    
}

extension ViewController {
    @objc func showKeyboard(notification: Notification){
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + kbFrameSize.height)
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrameSize.height, right: 0)
    }
    @objc func hideKeyboard() {
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
}
