//
//  Admin.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import Foundation

class Admin: User {
    @Published var founder: Bool = false
    
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
        print("Admin: Trying to upload data to Firestore")
        let document = Team.db.collection("admin_data").document(id)
        document.setData(data)
    }
    
    ///Delete admin data from Firestore.
    func delete() {
        Task {
            let adminDocRef = Team.db.collection("admin_data").document(id)
            try await adminDocRef.delete()
            
            print("Admin deleted successfully.")
            clearLocalAdminData()
        }
    }
    
    ///Clear local admin data.
    func clearLocalAdminData() {
        founder = false
        name = ""
        id = ""
        email = ""
    }
    
    
}
