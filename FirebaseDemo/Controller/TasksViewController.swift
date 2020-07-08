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
    
    @IBOutlet var tableView: UITableView!
    
    var fuser: FUser!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = Auth.auth().currentUser else {return}
        
        fuser = FUser(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(fuser.userId).child("tasks")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value) { [weak self](dataSnapshot) in
            var _tasks = Array<Task>()
            for item in dataSnapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tableView.reloadData()
        }
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
            let task = Task(title: textField.text!, userId: (self?.fuser.userId)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
}
extension TasksViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        isCompleted(cell, completed: task.completed)
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        let task = tasks[indexPath.row]
        let completed = !task.completed
        
        isCompleted(cell, completed: completed)
        task.ref?.updateChildValues(["completed": completed])
    }
    func isCompleted(_ cell: UITableViewCell, completed: Bool) {
        cell.accessoryType = completed ? .checkmark : .none
    }
    
}
