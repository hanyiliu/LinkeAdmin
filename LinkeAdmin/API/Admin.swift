//
//  Admin.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import Foundation

class Admin: User {
    var founder: Bool = false
    
    init(name: String, id: String, email: String, founder: Bool = false) {
        self.founder = founder
        super.init(name: name, id: id, email: email)
        uploadData(data: [
            "name": name,
            "id": id,
            "email": email
        ])
    }
    
    init(adminDictionary: [String:Any]) {
        super.init(name: adminDictionary["name"] as! String, id: adminDictionary["id"] as! String, email: adminDictionary["email"] as! String)
    }
    
    ///Upload admin data to Firebase
    func uploadData(data: [String:Any]) {
        print("Trying to upload data to Firestore")
        let document = Team.db.collection("admin_data").document(id)
        document.setData(data)

    }
    
    ///Clear local admin data.
    func clearLocalAdminData() {
        founder = false
        name = ""
        id = ""
        email = ""
    }
}
