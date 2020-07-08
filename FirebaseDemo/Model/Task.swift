//
//  Task.swift
//  FirebaseDemo
//
//  Created by   admin on 08/07/20.
//  Copyright © 2020 Evgeny Ezub. All rights reserved.
//

import Foundation
import  Firebase

struct Task {
    let title: String
    let userID: String
    let ref: DatabaseReference?
    let completed: Bool
    
    init(title: String, userID: String){
        self.title = title
        self.userID = userID
        self.ref = nil
        self.completed = false
    }
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        title = snapshotValue["title"] as! String
        userID = snapshotValue["userID"] as! String
        ref = snapshot.ref
        completed = snapshotValue["completed"] as! Bool
    }
    func convertToDictionary() -> Any {
        return ["title": title, "userId": userID, "completed": completed]
    }
}
