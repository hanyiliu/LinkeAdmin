//
//  User.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import Foundation

class User: ObservableObject, Identifiable, Hashable {
    var name: String
    var id: String
    var email: String
    
    init(name: String, id: String, email: String) {
        self.name = name
        self.id = id
        self.email = email
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    func getFirstName() -> String {
        let components = name.components(separatedBy: " ")
        if let firstName = components.first {
            return firstName
        }
        return name
    }
    
    func getLastName() -> String {
        let components = name.components(separatedBy: " ")
        if components.count > 1 {
            return components.last ?? ""
        }
        return ""
    }
}
