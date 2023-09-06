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
    
    @State private var latestAppVersion = ""
    @State private var showUpdateAppAlert = false
        
    
    @State private var isSortByActionSheetPresented = false
    
    @State private var fakeStudentCount = 0
    @State private var fakeAdminCount = 0
    
    
    static func studentStatusImage(for student: Student) -> some View {
        let symbol: String
        let color: Color
        
        switch student.status {
        case .outdated:
            symbol = "questionmark.circle.fill"
            color = Color.gray
        case .hasMissingAssignments:
            symbol = "exclamationmark.circle.fill"
            color = Color.red
        case .hasUpcomingAssignments:
            symbol = "exclamationmark.circle.fill"
            color = Color.yellow
        case .upToDate:
            symbol = "checkmark.circle.fill"
            color = Color.green
        }

        return Image(systemName: symbol)
            .foregroundColor(color)
    }
    
    
    private func fetchLatestAppVersion() {
        let infoRef = Team.db.collection("app_data").document("info")
        print("Checking app version.")
        infoRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let latestVersion = document.data()?["latest_version_admin"] as? String {
                    self.latestAppVersion = latestVersion
                    
                    // Compare with the current app version
                    if let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        if latestVersion != currentAppVersion {
                            // Display an alert if the versions do not match
                            showUpdateAppAlert = true
                        }
                    } else {
                        print("Cannot get app version.")
                    }
                } else {
                    print("Cannot find latest version in Firebase.")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
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
                            Section(header: Text("Team Groups")) {
                                if(admin.founder) {
                                    ForEach(team.studentGroups) { group in
                                        NavigationLink(destination: GroupView(group: group)) {
                                            Text(group.name)
                                        }
                                    }
                                    .onDelete(perform: team.deleteGroup)
                                } else {
                                    ForEach(team.studentGroups.filter { $0.admins.contains(where: { $0.id == admin.id }) }) { group in
                                        NavigationLink(destination: GroupView(group: group)) {
                                            Text(group.name)
                                        }
                                    }
                                    .onDelete(perform: team.deleteGroup)
                                }
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
                                            team.createGroup(name: enteredGroupName, currentAdmin: admin)
                                            team.refresh.toggle()
                                        }
                                    }
                                }
                            }
                            
                            
                            Section() {
                                NavigationLink(destination: TeachersView(team: team)) {
                                    Text("View Students by Teachers")
                                }
                                .disabled(!team.loaded)
                            }
                        }
                        
                        Section(header: HStack {
                            Text("Team Students\(team.students.count > 0 ? " - \(team.students.count) " + (team.students.count == 1 ? "student" : "students") : "")")
                            Spacer()
                            Button(action: {
                                isSortByActionSheetPresented = true
                            }) {
                                Text("Sort By")
                                Image(systemName: "arrow.up.arrow.down.circle")
                            }
                        }) {
                            if(team.students.count == 0) {
                                HStack {
                                    Spacer()
                                    Text("Tell your students tojoin with the student code!")
                                        .foregroundColor(Color.gray)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            } else {
                                ForEach(team.students) { student in
                                    NavigationLink(destination: StudentView(student: student)) {
                                        HomeView.studentStatusImage(for: student)
                                        Text(student.name)
                                        Spacer()
                                        switch student.status {
                                        case .outdated(let lastUpdated):
                                            let daysAgo = Calendar.current.dateComponents([.day], from: lastUpdated, to: Date()).day ?? 0
                                            Text("\(daysAgo) \(daysAgo == 1 ? "day" : "days") ago")
                                                .foregroundColor(.gray)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        case .hasMissingAssignments(let count):
                                            Text("\(count) missing")
                                                .foregroundColor(.red)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        case .hasUpcomingAssignments(let count):
                                            Text("\(count) upcoming")
                                                .foregroundColor(.yellow)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        case .upToDate:
                                            EmptyView()
                                        }
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            let studentID = student.id
                                            team.removeStudent(studentID: studentID)
                                        } label: {
                                            Text("Remove")
                                        }
                                    }
                                    
                                }
 
                            }
                        }.actionSheet(isPresented: $isSortByActionSheetPresented) {
                            ActionSheet(title: Text("Sort By:"), buttons: [
                                .default(Text("Status"), action: {
                                    team.sortOption = .status
                                }),
                                .default(Text("Last Name"), action: {
                                    team.sortOption = .lastName
                                }),
                                .default(Text("First Name"), action: {
                                    team.sortOption = .firstName
                                }),
                                .default(Text("Last Updated"), action: {
                                    team.sortOption = .lastUpdated
                                }),
                                .cancel()
                            ])
                        }
                    
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 10) {
                                StatusItemView(symbol: "questionmark.circle.fill", color: .gray, text: "- Not Updated")

                                StatusItemView(symbol: "exclamationmark.circle.fill", color: .red, text: "- Has Missing")
                            }
                            Spacer()
                            VStack(alignment: .leading, spacing: 10) {
                                StatusItemView(symbol: "exclamationmark.circle.fill", color: .yellow, text: "- Has Upcoming")
                                
                                StatusItemView(symbol: "checkmark.circle.fill", color: .green, text: "- All Good")
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
                                    .swipeActions {
                                        if !admin.founder {
                                            Button(role: .destructive) {
                                                let adminID = admin.id
                                                team.removeAdmin(adminID: adminID)
                                            } label: {
                                                Text("Remove")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Team Info")) {
                            
                            NavigationLink(destination: RenameView(title: "Team Name", currentValue: $team.teamName)) {
                                Text("Name")
                                Spacer()
                                Text(team.teamName)
                                    .foregroundColor(Color.gray)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            
                            HStack {
                                Text("Student Code")
                                Spacer()
                                Text(team.teamStudentCode).foregroundColor(Color.gray)
                            }
                            
                            HStack {
                                Text("Admin Code")
                                Spacer()
                                Text(team.teamAdminCode).foregroundColor(Color.gray)
                                
                            }
                            
                            HStack {
                                Text("Founder")
                                Spacer()
                                Text(team.admins.first(where: { $0.founder })?.name ?? "No Founder").foregroundColor(Color.gray)
                            }
                        }
                        

                    }
                    Section() {
                        
                        NavigationLink(destination: SettingsView(viewRouter: viewRouter, team: team, admin: admin)) {
                            Text("Settings")
                        }
                        
                        NavigationLink(destination: HelpView(viewRouter: viewRouter, fromHome: true)) {
                            Text("Help")
                        }
                        
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
                                    UpdateValue.saveToLocal(key: "SHOW_HELP", value: true)
                                    team.clearLocalTeamData()
                                    admin.clearLocalAdminData()
                                    viewRouter.currentPage = .googleSignIn
                                }),
                                secondaryButton: .cancel()
                            )
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
            .onAppear() {
                fetchLatestAppVersion()
            }
            .alert(isPresented: $showUpdateAppAlert) {
                Alert(
                    title: Text("Update Required"),
                    message: Text("A new version of the app is available. Please update to the latest version."),
                    primaryButton: .default(Text("Update"), action: {
                        // Open the App Store for the user to update the app
                        if let appStoreURL = URL(string: Bundle.main.infoDictionary!["APPSTORE_URL"] as! String) {
                            UIApplication.shared.open(appStoreURL)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
            
            
        } else {
            NavigationView {}.onAppear() {
                viewRouter.currentPage = .googleSignIn
            }
        }
    }
    
}
