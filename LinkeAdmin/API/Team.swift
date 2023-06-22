//
//  Team.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import Foundation
import FirebaseFirestore
import GoogleSignIn

class Team: ObservableObject {
    @Published var refresh: Bool = true //Call to refresh any views using this object
    @Published var teamCode = ""
    @Published var students: [Student] = []
    @Published var studentGroups: [Group] = []
    @Published var admins: [Admin] = []
    var teamID: String = ""
    
    static let db = Firestore.firestore()
    
    init(currentAdmin: Admin) {
        //Check if user has a team ID stored in local.
        if let id = UpdateValue.loadFromLocal(key: "TEAM_ID", type: "String") as? String {
            teamID = id
            Task {
                do {
                    if let teamDictionary = try await Team.fetchData(teamID: teamID) {
                        try await initializeTeam(teamDictionary: teamDictionary, currentAdmin: currentAdmin)
                    }
                } catch {
                    print("Error while trying to fetch team data: \(error)")
                }
            }
        }
        //Then check if user's ID is logged in a team's database.
        else {
            guard let adminID = GIDSignIn.sharedInstance.currentUser?.userID else { return }
            let teamDataRef = Firestore.firestore().collection("team_data")
            let query = teamDataRef.whereField("admins", arrayContains: adminID)
            Task {
                do {
                    let snapshot = try await query.getDocuments()
                    guard let document = snapshot.documents.first else {
                        print("Document not found")
                        return
                    }
                    
                    let teamDictionary = document.data()
                    try await initializeTeam(teamDictionary: teamDictionary, currentAdmin: currentAdmin)
                    
                } catch {
                    print("Error getting document: \(error)")
                }
            }
        }
        //If neither, current team is initialized as empty.

    }
    ///Initializes variables, given the dictionary.
    func initializeTeam(teamDictionary: [String: Any], currentAdmin: Admin? = nil) async throws {

        self.students = try await Team.initStudents(studentIDs: teamDictionary["students"] as! [String])

        admins = try await Team.initAdmins(adminIDs: teamDictionary["admins"] as! [String])
        admins.first(where: { $0.id == teamDictionary["team_founder"] as! String })?.founder = true
      
        if currentAdmin != nil {
            currentAdmin!.founder = true
        }
        
        studentGroups = initGroups(groups: teamDictionary["groups"] as! [[String : Any]])
        
        DispatchQueue.main.async {
            self.teamCode = teamDictionary["team_code"] as! String
        }
        teamID = teamDictionary["id"] as! String
    }
    
    ///Refresh team
    func refreshTeam() {
        guard teamCode != "" else { return }
        Task {
            do {
                if let teamDictionary = try await Team.fetchData(teamID: teamID) {
                    try await initializeTeam(teamDictionary: teamDictionary)
                }
            } catch {
                print("Error trying to initialize team dictionary: \(error)")
            }
        }
    }
    
    ///Join team
    func joinTeam(teamCode: String) {
        Task {
            let collectionRef = Firestore.firestore().collection("team_data")
            let query = collectionRef.whereField("team_code", isEqualTo: teamCode)
            
            do {
                let snapshot = try await query.getDocuments()
                
                guard let document = snapshot.documents.first else {
                    print("Team not found")
                    return
                }
                
                let teamDictionary = document.data()
                try await initializeTeam(teamDictionary: teamDictionary)
                appendAdminID(document: document.reference)
            } catch {
                print("Error getting team data: \(error)")
            }
        }
    }
    
    ///Creates team
    func createTeam(currentAdmin: Admin) {
        
        //let db = Firestore.firestore()
        //let collection = db.collection("team_data")

        teamID = UUID().uuidString
        //TODO: Check for uniqueness
        teamCode = generateTeamCode()
        //TODO: Check for uniqueness

        
        admins.append(Admin(name: GIDSignIn.sharedInstance.currentUser?.profile?.name ?? "",
                            id: GIDSignIn.sharedInstance.currentUser?.userID ?? "",
                            email: GIDSignIn.sharedInstance.currentUser?.profile?.email ?? "",
                            founder: true))
        currentAdmin.founder = true
        
        uploadData(data: createTeamData())
        UpdateValue.saveToLocal(key: "TEAM_ID", value: teamID)


    }
    
    ///Remove team from database.
    func deleteTeam(currentAdmin: Admin) {
        let documentRef = Team.db.collection("team_data").document(teamID)
        
        documentRef.delete { error in
            if let error = error {
                print("Error deleting team document: \(error)")
            } else {
                print("Team document deleted successfully.")
            }
        }
        
        clearLocalTeamData()
        currentAdmin.founder = false
    }
    
    ///Leave team
    func leaveTeam() {
        let documentRef = Team.db.collection("team_data").document(teamID)
        
        removeAdminID(document: documentRef)
        
        clearLocalTeamData()
    }
    
    ///Set all team values to nil / empty
    func clearLocalTeamData() {
        teamCode = ""
        students = []
        admins = []
        teamID = ""
    }

    ///Generates a random six-letter team code for use in the application.
    func generateTeamCode() -> String {
        // Generate a random team code
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let randomCode = String((0..<6).map { _ in letters.randomElement()! })
        
        // Set the team code
        return randomCode
    }
    
    ///Creates a team document
    func createTeamData() -> [String: Any] {

        var teamData: [String: Any] = [:]
        teamData["id"] = teamID
        teamData["team_code"] = teamCode
        teamData["team_founder"] = admins.first(where: { $0.founder })!.id
        
        var studentArray: [String] = []
        for student in students {
            studentArray.append(student.id)
        }
        teamData["students"] = studentArray
        
        var adminArray: [String] = []
        for admin in admins {
            adminArray.append(admin.id)
        }
        teamData["admins"] = adminArray
        
        teamData["groups"] = []
        

        
        return teamData
    }
    
    ///Upload team data to Firebase
    func uploadData(data: [String:Any]) {
        print("Trying to upload data to Firestore")
        let document = Team.db.collection("team_data").document("\(teamID)")
        document.setData(data)
    }
    
    ///Add admin's iD to the team document's admins array.
    func appendAdminID(document: DocumentReference) {
        guard let id = GIDSignIn.sharedInstance.currentUser?.userID else {
            print("No admin ID found.")
            return
        }
        
        document.updateData(["admins": FieldValue.arrayUnion([id])]) { error in
            if let error = error {
                print("Error appending ID to admins array: \(error)")
            } else {
                print("ID appended to admins array successfully")
            }
        }
    }
    
    ///Remove admin's iD from the team document's admins array.
    func removeAdminID(document: DocumentReference) {
        guard let id = GIDSignIn.sharedInstance.currentUser?.userID else {
            print("No admin ID found.")
            return
        }
        
        document.updateData(["admins": FieldValue.arrayRemove([id])]) { error in
            if let error = error {
                print("Error removing ID from admins array: \(error)")
            } else {
                print("ID removed from admins array successfully")
            }
        }
    }
    
    ///Create new empty group
    func createGroup(name: String, founderID: String) {
        studentGroups.append(Group(team: self, name: name, id: "\(studentGroups.count)", founder: admins.first(where: { $0.id == founderID } )!))
    }
    
    ///Delete group
    func deleteGroup(at offsets: IndexSet) {
        // Remove the groups from the studentGroups array
        studentGroups.remove(atOffsets: offsets)
        
        // Delete the corresponding groups from Firebase
        let teamsCollection = Team.db.collection("team_data")
        let teamDocument = teamsCollection.document(teamID)
        Task {
            do {
                var groupsArray: [[String: Any]] = []
                
                let snapshot = try await teamDocument.getDocument()
                if snapshot.exists {
                    // Team document exists
                    if let existingGroups = snapshot.data()?["groups"] as? [[String: Any]] {
                        // Remove the groups from the existing groups array
                        groupsArray = existingGroups
                        groupsArray.remove(atOffsets: offsets)
                    }
                    
                    // Update the groups array in the team document
                    try await teamDocument.setData([
                        "groups": groupsArray
                    ], merge: true)
                    
                    print("Group deleted successfully")
                } else {
                    print("Team document doesn't exist")
                }
            } catch {
                print("Error deleting group: \(error)")
            }
        }
    }
    
    ///Return all teacher's names with their corresponding # of students.
    func getTeachersByStudentCount() -> [(String, Int, [(Student, String)])] {
        print("called")
        var teachersWithStudents: [(String, Int, [(Student, String)])] = []
        
        // Create a dictionary to store teachers and their associated students
        var teacherStudentsDict: [String: [(Student, String)]] = [:]
        
        // Iterate over all students
        for student in students {
            // Iterate over each student's classrooms
            for classroom in student.classrooms {
                // Append the student to the teacher's array in the dictionary
                teacherStudentsDict[classroom.teacherName, default: []].append((student, classroom.name))
            }
        }
        
        // Sort teachers by student count in descending order
        let sortedTeachers = teacherStudentsDict.sorted { $0.value.count > $1.value.count }
        
        // Create the result array with teacher name, student count, and associated students
        for (teacherName, students) in sortedTeachers {
            let sortedStudents = students.sorted { $0.1 < $1.1 } // Sort by the associated string
            let studentCount = students.count
            teachersWithStudents.append((teacherName, studentCount, sortedStudents))
        }
        
        return teachersWithStudents
    }

    
    ///Fetch team data from Firebase. Returns team dictionary.
    static func fetchData(teamID: String) async throws -> [String: Any]? {
        let collectionRef = db.collection("team_data")
        let documentRef = collectionRef.document(teamID)

        do {
            let document = try await documentRef.getDocument()
            
            if document.exists {
                if let data = document.data() {
                    return data
                }
            }
        } catch {
            throw error
        }

        // Return empty arrays if the document or the required fields are not found
        return nil
    }
    
    ///Initializes students array, given all students' IDs.
    static func initStudents(studentIDs: [String]) async throws -> [Student] {
        let collectionRef = db.collection("student_data")
        
        var students: [Student] = []
        
        for studentID in studentIDs {
            do {
                let doc = try await collectionRef.document(studentID).getDocument()
                if let data = doc.data() {
                    students.append(Student(studentDictionary: data))
                }
            } catch {
                throw error
            }
        }
        return students
    }
    
    ///Initializes admins array, given all admins' IDs.
    static func initAdmins(adminIDs: [String]) async throws -> [Admin] {
        let collectionRef = db.collection("admin_data")

        var admins: [Admin] = []
        for adminID in adminIDs {
            do {
                let doc = try await collectionRef.document(adminID).getDocument()
                if let data = doc.data() {
                    admins.append(Admin(adminDictionary: data))
                }
            } catch {
                throw error
            }
        }
        return admins
    }
    
    ///Initializes groups, given all groups data.
    func initGroups(groups: [[String: Any]]) -> [Group] {
        var studentGroups: [Group] = []
        
        for groupData in groups {
            guard
                let name = groupData["name"] as? String,
                let id = groupData["id"] as? String,
                let studentIDs = groupData["students"] as? [String],
                let adminIDs = groupData["admins"] as? [String]
            else {
                continue
            }
            
            let group = Group(team: self, name: name, id: id)
            
            // Initialize students
            group.students = studentIDs.compactMap { studentID in
                // Find the student with the matching ID in the Team's students array
                return students.first { $0.id == studentID }
            }
            
            // Initialize admins
            group.admins = adminIDs.compactMap { adminID in
                // Find the admin with the matching ID in the Team's admins array
                return admins.first { $0.id == adminID }
            }
            
            studentGroups.append(group)
        }
        
        return studentGroups
    }
}
