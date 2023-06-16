//
//  Group.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/15/23.
//

import Foundation
import FirebaseFirestore
class Group: ObservableObject, Identifiable {
    var team: Team
    var name: String
    var id: String
    @Published var students: [Student]
    @Published var admins: [Admin]

    
    init(team: Team, name: String, id: String) {
        self.team = team
        self.name = name
        self.id = id
        self.students = []
        self.admins = []
        
        Task {
            await uploadData()
        }
    }
    
    ///Add student to group.
    func addStudent(student: Student) {
        guard !students.contains(where: { $0.id == student.id }) else {
            return
        }
        students.append(student)
        
        Task {
            await uploadData()
        }
    }
    
    ///Add admin to group.
    func addAdmin(admin: Admin) {
        guard !admins.contains(where: { $0.id == admin.id }) else {
            return
        }
        admins.append(admin)
        
        Task {
            await uploadData()
        }
    }
    
    ///Upload group data to Firebase Firestore.
    func uploadData() async {
        let db = Team.db
        let teamsCollection = db.collection("team_data")
        let teamDocument = teamsCollection.document(team.teamID)
        
        // Create a dictionary representation of the current group
        let groupData: [String: Any] = [
            "name": name,
            "id": id,
            "students": students.map { $0.id },
            "admins": admins.map { $0.id }
        ]
        
        do {
            var groupsArray: [[String: Any]] = []
            
            let snapshot = try await teamDocument.getDocument()
            if snapshot.exists {
                // Team document exists
                if let existingGroups = snapshot.data()?["groups"] as? [[String: Any]] {
                    // Append the updated group data to the existing groups array
                    groupsArray = existingGroups
                    if let index = groupsArray.firstIndex(where: { $0["id"] as? String == id }) {
                        // Replace the existing group data if the group already exists in the array
                        groupsArray[index] = groupData
                    } else {
                        // Append the new group data if the group doesn't exist in the array
                        groupsArray.append(groupData)
                    }
                } else {
                    // No existing groups array, create a new array with the current group data
                    groupsArray = [groupData]
                }
                
                // Update the groups array in the team document
                try await teamDocument.setData([
                    "groups": groupsArray
                ], merge: true)
                
                print("Group data updated successfully")
            } else {
                print("Team document doesn't exist")
            }
        } catch {
            print("Error uploading group data: \(error)")
        }
    }

    
    
}
