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
    var admins: [Admin] = []
    var teamID: String = ""
    
    static let db = Firestore.firestore()
    
    init() {
        //Check if user has a team ID stored in local.
        if let id = UpdateValue.loadFromLocal(key: "TEAM_ID", type: "String") as? String {
            teamID = id
            Task {
                do {
                    if let teamDictionary = try await Team.fetchData(teamID: teamID) {
                        try await initializeTeam(teamDictionary: teamDictionary)
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
                    try await initializeTeam(teamDictionary: teamDictionary)
                    
                } catch {
                    print("Error getting document: \(error)")
                }
            }
        }
        //If neither, current team is initialized as empty.

    }
    ///Initializes variables, given the dictionary.
    func initializeTeam(teamDictionary: [String: Any]) async throws {

        self.students = try await Team.initStudents(studentIDs: teamDictionary["students"] as! [String])

        admins = try await Team.initAdmins(adminIDs: teamDictionary["admins"] as! [String])
        admins.first(where: { $0.id == teamDictionary["team_founder"] as! String })?.founder = true
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
}
