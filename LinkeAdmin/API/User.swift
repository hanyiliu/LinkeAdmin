//
//  User.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import Foundation

class User: ObservableObject, Identifiable {
    var name: String
    var id: String
    var email: String
    
    init(name: String, id: String, email: String) {
        self.name = name
        self.id = id
        self.email = email
    }
}
