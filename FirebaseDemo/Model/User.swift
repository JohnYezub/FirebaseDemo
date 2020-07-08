//
//  User.swift
//  FirebaseDemo
//
//  Created by   admin on 08/07/20.
//  Copyright © 2020 Evgeny Ezub. All rights reserved.
//

import Foundation
import Firebase
struct FUser {
    let userId: String
    let email: String?
    init(user: User ) {
        self.userId = user.uid
        self.email = user.email
    }
}
