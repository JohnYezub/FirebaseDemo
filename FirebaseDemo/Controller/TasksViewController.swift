//
//  TasksViewController.swift
//  FirebaseDemo
//
//  Created by   admin on 07/07/20.
//  Copyright © 2020 Evgeny Ezub. All rights reserved.
//

import UIKit
import Firebase
class TasksViewController: UIViewController {

    var fuser: FUser!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = Auth.auth().currentUser else {return}
        
        fuser = FUser(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(fuser.userID).child("tasks")
        // Do any additional setup after loading the view.
    }
    @IBAction func signOut(_ sender: Any) {
        do {
        try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTask(_ sender: Any) {
        let alertController = UIAlertController(title: "Add new Task", message: "Type new task", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let save = UIAlertAction(title: "Save", style: .default) { [weak self]_ in
            guard let textField = alertController.textFields?.first, textField.text != "" else {return}
            let task = Task(title: textField.text!, userID: (self?.fuser.userID)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
}
extension TasksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .clear
        return cell
    }
    
    
}
