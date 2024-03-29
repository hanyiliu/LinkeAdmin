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
    @Published var teamStudentCode = ""
    @Published var teamAdminCode = ""
    @Published var students: [Student] = []
    @Published var studentGroups: [Group] = []
    @Published var admins: [Admin] = []
    
    
    @Published private var _sortOption: SortOption = .lastName
    var sortOption: SortOption {
        get {
            _sortOption
        }
        set {
            _sortOption = newValue
            sortStudents(by: newValue)
            UpdateValue.saveToLocal(key: "SORT_OPTION", value: newValue)
        }
    }
    
    @Published private var _teamName = ""
    var teamName: String {
        get {
            _teamName
        }
        set {
            _teamName = newValue
            
            Task {
                let teamRef = Team.db.collection("team_data").document(teamID)
                
                do {
                    try await teamRef.setData(["name": newValue], merge: true)
                } catch {
                    throw error
                }
            }
            
        }
    }

    var teamID: String = ""
    
    private var _studentsSortedByTeachers: [(String, Int, [(Student, String)])]?
    var studentsSortedByTeachers: [(String, Int, [(Student, String)])] {
        get {
            if _studentsSortedByTeachers == nil {
                _studentsSortedByTeachers = getStudentsSortedByTeachers()
            }
            return _studentsSortedByTeachers!
        }
        set {
            _studentsSortedByTeachers = newValue
        }
    }
    
    @Published var loaded = false
    static let db = Firestore.firestore()
    
    init(currentAdmin: Admin, viewRouter: ViewRouter) {
        viewRouter.currentPage = .loading
        print("Starting to load team.")
        
        //Check if user has a team ID stored in local.
        if let id = UpdateValue.loadFromLocal(key: "TEAM_ID", type: "String") as? String, id.count != 0 {
            teamID = id
            loadTeamWithID(currentAdmin: currentAdmin, viewRouter: viewRouter)
        }
        //Then check if user's ID is logged in a team's database.
        else {
            guard let adminID = GIDSignIn.sharedInstance.currentUser?.userID else {
                //User isn't signed in.
                viewRouter.currentPage = .googleSignIn
                return
            }
            let teamDataRef = Firestore.firestore().collection("team_data")
            let query = teamDataRef.whereField("admins", arrayContains: adminID)
            
            loadTeamWithDatabase(query: query, currentAdmin: currentAdmin, viewRouter: viewRouter)
        }
        //If neither, current team is initialized as empty.
        
        DispatchQueue.main.async {
            if let data = UpdateValue.loadFromLocal(key: "SHOW_HELP", type: "Bool") as? Bool {
                if data {
                    viewRouter.currentPage = .help
                } else {
                    viewRouter.currentPage = .home
                }
            } else {
                viewRouter.currentPage = .help
            }
        }
        
    }
    
    //Given team ID, prepare teamDictionary to pass to initializeTeam.
    func loadTeamWithID(currentAdmin: Admin, viewRouter: ViewRouter) {
        Task {
            do {
                if let teamDictionary = try await fetchData() {
                    print("Team ID stored at local. Using it to initialize team.")
                    try await initializeTeam(teamDictionary: teamDictionary, currentAdmin: currentAdmin)
                } else {
                    print("Data not found using Team ID.")
                }
            } catch {
                print("Error while trying to fetch team data: \(error)")
            }
            print("Finished loading team.")
        }
    }
    
    //Given query of document containing current admin's ID, prepare teamDictionary to pass to initializeTeam.
    func loadTeamWithDatabase(query: Query, currentAdmin: Admin, viewRouter: ViewRouter) {
        Task {
            do {
                let snapshot = try await query.getDocuments()
                guard let document = snapshot.documents.first else {
                    print("Document not found")
                    //User not part of any teams.
                    viewRouter.currentPage = .home
                    return
                }
                
                let teamDictionary = document.data()
                print("Admin found to be part of team online. Using it to initialize team.")
                try await initializeTeam(teamDictionary: teamDictionary, currentAdmin: currentAdmin)
                
            } catch {
                print("Error getting document: \(error)")
            }
            print("Finished loading team.")
        }
    }
    
    ///Initializes variables, given the dictionary.
    func initializeTeam(teamDictionary: [String: Any], currentAdmin: Admin? = nil) async throws {
        teamID = teamDictionary["id"] as! String
        
        DispatchQueue.main.async {
            self.teamStudentCode = teamDictionary["student_code"] as! String
            self.teamAdminCode = teamDictionary["admin_code"] as! String
            self.teamName = teamDictionary["name"] as? String ?? ""
        }
        
        try await initStudents(studentIDs: teamDictionary["students"] as! [String])
        try await initAdmins(adminIDs: teamDictionary["admins"] as! [String])
        
        admins.first(where: { $0.id == teamDictionary["team_founder"] as! String })?.founder = true
        
        if currentAdmin != nil, currentAdmin!.id == teamDictionary["team_founder"] as! String {
            currentAdmin!.founder = true
        }
        
        DispatchQueue.main.async {
            self.studentGroups = self.initGroups(groups: teamDictionary["groups"] as! [[String : Any]])
            
            if let sortOption = UpdateValue.loadFromLocal(key: "SORT_OPTION", type: "SortOption") as? SortOption {
                self.sortOption = sortOption
            } else {
                self.sortStudents(by: self.sortOption)
            }
            self.loaded = true
        }
        
        
    }
    
    ///Refresh team
    func refreshTeam() {
        guard teamAdminCode != "" else { return }
        loaded = false
        _studentsSortedByTeachers = nil
        students = []
        admins = []
        Task {
            do {
                if let teamDictionary = try await fetchData() {
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
            let query = collectionRef.whereField("admin_code", isEqualTo: teamCode)
            
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
        (teamStudentCode, teamAdminCode) = generateTeamCodes()
        //TODO: Check for uniqueness
        
        
        admins.append(Admin(name: GIDSignIn.sharedInstance.currentUser?.profile?.name ?? "",
                            id: GIDSignIn.sharedInstance.currentUser?.userID ?? "",
                            email: GIDSignIn.sharedInstance.currentUser?.profile?.email ?? "",
                            founder: true))
        currentAdmin.founder = true
        
        teamName = "\(currentAdmin.name)'s Team"
        
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
        teamStudentCode = ""
        teamAdminCode = ""
        students = []
        admins = []
        teamID = ""
        UpdateValue.saveToLocal(key: "TEAM_ID", value: "")
    }
    
    ///Generates a random six-letter team code for use in the application.
    func generateTeamCodes() -> (String, String) {
        // Generate a random team code
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let randomStudentCode = String((0..<6).map { _ in letters.randomElement()! })
        let randomAdminCode = String((0..<7).map { _ in letters.randomElement()! })
        
        // Set the team code
        return (randomStudentCode, randomAdminCode)
    }
    
    ///Creates a team document
    func createTeamData() -> [String: Any] {
        
        let founder = admins.first(where: { $0.founder })!
        var teamData: [String: Any] = [:]
        teamData["id"] = teamID
        teamData["student_code"] = teamStudentCode
        teamData["admin_code"] = teamAdminCode
        teamData["team_founder"] = founder.id
        teamData["name"] = teamName.count == 0 ? "\(founder.name)'s Team" : teamName
        
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
        print("Team: Trying to upload data to Firestore")
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
    
    ///Remove admin's ID from the team document's admins array.
    func removeAdminID(document: DocumentReference, adminID: String) {
        document.updateData(["admins": FieldValue.arrayRemove([adminID])]) { error in
            if let error = error {
                print("Error removing ID \(adminID) from admins array: \(error)")
            } else {
                print("ID removed from admins array successfully")
            }
        }
    }
    
    ///Remove student's ID from the team document's students array.
    func removeStudentID(document: DocumentReference, studentID: String) {
        document.updateData(["students": FieldValue.arrayRemove([studentID])]) { error in
            if let error = error {
                print("Error removing ID \(studentID) from students array: \(error)")
            } else {
                print("ID removed from students array successfully")
            }
        }
    }

    ///Remove admin from Team.
    func removeAdmin(adminID: String) {
        if let index = admins.firstIndex(where: { $0.id == adminID }) {
            admins.remove(at: index)
            
            // Call your removeAdminID function here
            let documentRef = Team.db.collection("team_data").document(teamID)
            removeAdminID(document: documentRef, adminID: adminID)
        }
    }

    
    ///Remove student from Team.
    func removeStudent(studentID: String) {
        if let index = students.firstIndex(where: { $0.id == studentID }) {
            students.remove(at: index)
            removeStudentFromTeachersSorted(studentID: studentID)
            // Call your removeStudentID function here
            let documentRef = Team.db.collection("team_data").document(teamID)
            removeStudentID(document: documentRef, studentID: studentID)
        }
    }

    func sortStudents(by sortOption: SortOption) {
        switch sortOption {
        case .status:
            // Sort students by status
            students.sort { student1, student2 in
                return student1.status < student2.status
            }

        case .lastName:
            // Sort students by last name
            students.sort { student1, student2 in
                return student1.getLastName() < student2.getLastName()
            }
        case .firstName:
            // Sort students by first name
            students.sort { student1, student2 in
                student1.getFirstName() < student2.getFirstName()
            }
        case .lastUpdated:
            // Sort students by last updated
            students.sort { student1, student2 in
                student1.lastUpdated < student2.lastUpdated
            }
        }
        
        // Notify that the data has changed
        refresh.toggle()
    }
    
    ///Create new empty group
    func createGroup(name: String, currentAdmin: Admin) {
        studentGroups.append(Group(team: self, name: name, id: "\(studentGroups.count)", currentAdmin: currentAdmin))
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
    func getStudentsSortedByTeachers() -> [(String, Int, [(Student, String)])] {
        print("Sorting called")
        var teachersWithStudents: [(String, Int, [(Student, String)])] = []
        
        // Create a dictionary to store teachers and their associated students
        var teacherStudentsDict: [String: [(Student, String)]] = [:]
        
        // Iterate over all students
        for student in students {
            // Iterate over each student's classrooms
            for classroom in student.classrooms.filter { !$0.hiddenByStudent } {
                
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
    
    /// Remove student from teachersByStudentSorted and update counts.
    func removeStudentFromTeachersSorted(studentID: String) {
        // Check if the sorted list is initialized
        guard _studentsSortedByTeachers != nil else {
            return
        }
        
        // Iterate through each teacher's students
        for (index, (teacherName, _, students)) in _studentsSortedByTeachers!.enumerated() {
            let updatedStudents = students.filter { student, _ in
                student.id != studentID
            }
            let updatedStudentCount = updatedStudents.count
            
            _studentsSortedByTeachers![index] = (teacherName, updatedStudentCount, updatedStudents)
        }
    }


    
    ///Fetch team data from Firebase. Returns team dictionary.
    func fetchData() async throws -> [String: Any]? {
        let collectionRef = Team.db.collection("team_data")
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
    func initStudents(studentIDs: [String]) async throws {
        let collectionRef = Team.db.collection("student_data")

        for studentID in studentIDs {
            do {
                let doc = try await collectionRef.document(studentID).getDocument()
                if let data = doc.data() {
                    DispatchQueue.main.async {
                        self.students.append(Student(studentDictionary: data))
                    }
                }
            } catch {
                throw error
            }
        }
    }
    
    ///Initializes admins array, given all admins' IDs.
    func initAdmins(adminIDs: [String]) async throws {
        let collectionRef = Team.db.collection("admin_data")
      
        for adminID in adminIDs {
            do {
                let doc = try await collectionRef.document(adminID).getDocument()
                if let data = doc.data() {
                    DispatchQueue.main.async {
                        self.admins.append(Admin(adminDictionary: data))
                    }
                }
            } catch {
                throw error
            }
        }
    }
    
    ///Initializes groups, given all groups data.
    func initGroups(groups: [[String: Any]]) -> [Group] {
        var studentGroups: [Group] = []
        
        for groupData in groups {
            guard let name = groupData["name"] as? String,
                  let id = groupData["id"] as? String,
                  let studentIDs = groupData["students"] as? [String],
                  let adminIDs = groupData["admins"] as? [String]
            else {
                continue
            }
            print("ids: \(studentIDs)")
            print("students: \(students)")
            // Initialize students
            let groupStudents = studentIDs.compactMap { studentID in
                // Find the student with the matching ID in the Team's students array
                return students.first { $0.id == studentID }
            }
            
            // Initialize admins
            let groupAdmins = adminIDs.compactMap { adminID in
                // Find the admin with the matching ID in the Team's admins array
                return admins.first { $0.id == adminID }
            }
            
            let group = Group(team: self, name: name, id: id, students: groupStudents, admins: groupAdmins)
            
            studentGroups.append(group)
        }
        
        return studentGroups
    }
}

enum SortOption: String, CaseIterable, Identifiable, Codable {
    case status = "Status"
    case lastName = "Last Name"
    case firstName = "First Name"
    case lastUpdated = "Last Updated"
    
    var id: SortOption { self }
}


