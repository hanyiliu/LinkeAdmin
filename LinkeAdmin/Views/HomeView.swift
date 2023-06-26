//
//  HomeView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import Foundation
import SwiftUI
import GoogleSignIn
import FirebaseFirestore

struct HomeView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var viewRouter: ViewRouter
    @StateObject var team: Team
    @StateObject var admin: Admin
    
    @State private var showSignOutConfirmation = false
    @State private var showConfirmation = false //For deleting team
    
    @State private var showAlert = false //For entering team code to join
    @State private var enteredCode = "" //---
    
    @State private var showCreateGroupAlert = false //For entering new group name
    @State private var enteredGroupName = "" //---
    
    @State private var fakeStudentCount = 0
    @State private var fakeAdminCount = 0
    
    var body: some View {
        let user = GIDSignIn.sharedInstance.currentUser
        
        if let profile = user?.profile {
            NavigationView {
                Form {
                    if team.teamAdminCode == "" {
                        Section() {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        team.createTeam(currentAdmin: admin)
                                        team.refresh.toggle()
                                    }) {
                                        HStack {
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(.blue)
                                                    .frame(width: UIScreen.main.bounds.size.width/15, height: UIScreen.main.bounds.size.width/15) // Adjust the size of the circle
                                                
                                                Image(systemName: "plus")
                                                    .foregroundColor(.white)
                                                    .frame(width: UIScreen.main.bounds.size.width/20, height: UIScreen.main.bounds.size.width/20) // Adjust the size of the circle
                                            }
                                            
                                            
                                            Text("Create a Team")
                                                .foregroundColor(.blue)
                                                .font(.headline)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.all)
                                Spacer()
                            }
                        }
                        
                        Section() {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showAlert = true
                                        
                                    }) {
                                        HStack {
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(.blue)
                                                    .frame(width: UIScreen.main.bounds.size.width/15, height: UIScreen.main.bounds.size.width/15) // Adjust the size of the circle
                                                
                                                Image(systemName: "arrow.right")
                                                    .foregroundColor(.white)
                                                    .frame(width: UIScreen.main.bounds.size.width/20, height: UIScreen.main.bounds.size.width/20) // Adjust the size of the circle
                                            }
                                            
                                            
                                            Text("Join a Team")
                                                .foregroundColor(.blue)
                                                .font(.headline)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                            Spacer()
                                        }
                                    }.alert("Enter Team Admin Code", isPresented: $showAlert) {
                                        TextField("TUVWXYZ", text: $enteredCode)
                                        HStack {
                                            Button("Cancel") {
                                                showAlert = false
                                            }
                                            Button("Join") {
                                                team.joinTeam(teamCode: enteredCode.uppercased())
                                                team.refresh.toggle()
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.all)
                                Spacer()
                            }
                        }
                    
                    } else {
                        if(team.students.count != 0) {
                            if(admin.founder) {
                                Section(header: Text("Team Groups")) {
                                    ForEach(team.studentGroups) { group in
                                        NavigationLink(destination: GroupView(group: group)) {
                                            Text(group.name)
                                        }
                                    }
                                    .onDelete(perform: team.deleteGroup)
                                    Button("Create New Group") {
                                        showCreateGroupAlert = true
                                    }
                                    .alert("Enter Group Name", isPresented: $showCreateGroupAlert) {
                                        TextField("Enter Group Name", text: $enteredGroupName)
                                        HStack {
                                            Button("Cancel") {
                                                showCreateGroupAlert = false
                                            }
                                            Button("Create") {
                                                team.createGroup(name: enteredGroupName, founderID: admin.id)
                                                team.refresh.toggle()
                                            }
                                        }
                                    }
                                }
                            } else {
                                Section(header: Text("Team Groups")) {
                                    ForEach(team.studentGroups.filter { $0.admins.contains(where: { $0.id == admin.id }) }) { group in
                                        NavigationLink(destination: GroupView(group: group)) {
                                            Text(group.name)
                                        }
                                    }
                                }
                            }
                            
                            Section() {
                                NavigationLink(destination: TeachersView(team: team, teachersByStudentCount: team.teachersByStudentSorted)) {
                                    Text("View Students by Teachers")
                                }
                            }
                        }
                        
                        Section(header: Text("Team Info")) {
                            HStack {
                                Text("Team Student Code")
                                Spacer()
                                Text(team.teamStudentCode).foregroundColor(Color.gray)
                            }
                            
                            HStack {
                                Text("Team Admin Code")
                                Spacer()
                                Text(team.teamAdminCode).foregroundColor(Color.gray)
                            }
                            
                            HStack {
                                Text("Founder")
                                Spacer()
                                Text(team.admins.first(where: { $0.founder })?.name ?? "No Founder").foregroundColor(Color.gray)
                            }
                        }
                        
                        Section(header: Text("Team Students")) {
                            if(team.students.count == 0) {
                                HStack {
                                    Spacer()
                                    Text("Tell your students to join with the student code!")
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            } else {
                                ForEach(team.students) { student in
                                    NavigationLink(destination: StudentView(student: student)) {
                                        Text(student.name)
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Team Admins")) {
                            if(team.admins.count == 1) {
                                HStack {
                                    Spacer()
                                    Text("Tell your admins to join with the admin code!")
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            } else {
                                ForEach(team.admins) { admin in
                                    Text(admin.name)
                                }
                            }
                        }

                    }
                    Section() {
                        if team.teamAdminCode != "" {
                            if(admin.founder) {
                                Button(action: {
                                    showConfirmation = true
                                }) {
                                    Text("Delete Team")
                                        .foregroundColor(.red)
                                }
                                .alert(isPresented: $showConfirmation) {
                                    Alert(
                                        title: Text("Delete Team"),
                                        message: Text("Are you sure you want to delete the team?"),
                                        primaryButton: .destructive(Text("Delete"), action: {
                                            team.deleteTeam(currentAdmin: admin)
                                        }),
                                        secondaryButton: .cancel()
                                    )
                                }
                            } else {
                                Button(action: {
                                    showConfirmation = true
                                }) {
                                    Text("Leave Team")
                                        .foregroundColor(.red)
                                }
                                .alert(isPresented: $showConfirmation) {
                                    Alert(
                                        title: Text("Leave Team"),
                                        message: Text("Are you sure you want to leave the team?"),
                                        primaryButton: .destructive(Text("Leave"), action: {
                                            team.leaveTeam()
                                        }),
                                        secondaryButton: .cancel()
                                    )
                                }
                            }
                        }
                        
                        Button(action: {
                            showSignOutConfirmation = true
                        }) {
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showSignOutConfirmation) {
                            Alert(
                                title: Text("Sign Out"),
                                message: Text("Are you sure you want to sign out?"),
                                primaryButton: .destructive(Text("Sign Out"), action: {
                                    GIDSignIn.sharedInstance.signOut()
                                    team.clearLocalTeamData()
                                    admin.clearLocalAdminData()
                                    viewRouter.currentPage = .googleSignIn
                                }),
                                secondaryButton: .cancel()
                            )
                        }
                    }
                    
                    Section(header: Text("REMOVE AT RELEASE")) {
                        Button("Add fake student to team") {
                            //Create fake dictionary
                            let studentID = "0000\(fakeStudentCount)"
                            var studentDictionary: [String: Any] = [:]
                            studentDictionary["name"] = "John Doe \(fakeStudentCount)"
                            studentDictionary["id"] = studentID
                            studentDictionary["email"] = "john.doe\(fakeStudentCount)@example.com"
                            studentDictionary["last_updated"] = Date()
                            let classroomCount = fakeStudentCount / 3
                            let randomInt = Int.random(in: 0...2)
                            var classroomArray: [[String: Any]] = []
                            var classroom: [String: Any] = ["name": "Math \(fakeStudentCount / 5 + randomInt)", "id": "12345\(fakeStudentCount / 5 + randomInt)", "teacher_id" : "4440", "teacher_name" : "Bobby Joe 0"]
                            let assignment1 = ["name": "Homework 1", "id": "1", "due_date": ["year": 2023, "month": 6, "day": 15]] as [String : Any]
                            let assignment2 = ["name": "Homework 2", "id": "2", "due_date": ["year": 2023, "month": 6, "day": 20]] as [String : Any]
                            classroom["assignment"] = [assignment1, assignment2]
                            classroomArray.append(classroom)
                            
                            studentDictionary["classroom"] = classroomArray
                            //End fake dictionary creation
                            
                            fakeStudentCount += 1
                            
                            print("Fake Student: Trying to upload data to Firestore")
                            let studentDocument = Team.db.collection("student_data").document(studentID)
                            studentDocument.setData(studentDictionary)
                            
                            let teamDocument = Team.db.collection("team_data").document(team.teamID)
                            teamDocument.updateData(["students": FieldValue.arrayUnion([studentID])]) { error in
                                if let error = error {
                                    print("Error appending ID to students array: \(error)")
                                } else {
                                    print("ID appended to students array successfully")
                                }
                            }
                        }
                        
                        Button("Add fake admin to team") {
                            //Create fake dictionary
                            let adminID = "9999\(fakeAdminCount)"
                            var adminDictionary: [String: Any] = [:]
                            adminDictionary["name"] = "Jake Dan \(fakeAdminCount)"
                            adminDictionary["id"] = adminID
                            adminDictionary["email"] = "jake.dan\(fakeAdminCount)@example.com"

                            //End fake dictionary creation
                            
                            fakeAdminCount += 1
                            
                            print("Fake Admin: Trying to upload data to Firestore")
                            let adminDocument = Team.db.collection("admin_data").document(adminID)
                            adminDocument.setData(adminDictionary)
                            
                            let teamDocument = Team.db.collection("team_data").document(team.teamID)
                            teamDocument.updateData(["admins": FieldValue.arrayUnion([adminID])]) { error in
                                if let error = error {
                                    print("Error appending ID to admins array: \(error)")
                                } else {
                                    print("ID appended to admins array successfully")
                                }
                            }
                        }
                    }
                    Logo()
                    
                }
                
                .navigationTitle("Hello, \(profile.name)")
                .navigationBarItems(trailing:
                                        Button(action: {
                    team.refreshTeam()
                }) {
                    Image(systemName: "arrow.clockwise").foregroundColor(.blue)
                })
                
            }.navigationViewStyle(StackNavigationViewStyle())
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        team.refreshTeam()
                    }
                }
            
            
        } else {
            NavigationView {}.onAppear() {
                viewRouter.currentPage = .googleSignIn
            }
        }
    }
    
}

struct Logo: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var body: some View {
        Section {
            HStack(alignment: .bottom) {
                VStack {
                    Image("GrayIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.size.width/4)
                    Text("Linke for Admins v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                        .foregroundColor(.gray)
                        .font(.system(size: 11.0))
                    Text("Ⓒ Hanyi Liu 2023")
                        .foregroundColor(.gray)
                        .font(.system(size: 11.0))
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .listRowInsets(EdgeInsets())
            .background(Color(.systemGroupedBackground))
        
    }
}
