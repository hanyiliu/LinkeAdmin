//
//  HomeView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import Foundation
import SwiftUI
import GoogleSignIn

struct HomeView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var viewRouter: ViewRouter
    @StateObject var team: Team
    @StateObject var admin: Admin
    
    @State private var showSignOutConfirmation = false
    @State private var showConfirmation = false //For deleting team
    @State private var showAlert = false //For entering tema code to join
    @State private var enteredCode = "" //---
    
    var body: some View {
        let user = GIDSignIn.sharedInstance.currentUser
        
        if let profile = user?.profile {
            NavigationView {
                Form {
                    if team.teamCode == "" {
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
                                    }.alert("Enter Team Code", isPresented: $showAlert) {
                                        TextField("Enter Team Code", text: $enteredCode)
                                        HStack {
                                            Button("Cancel") {
                                                showAlert = false
                                            }
                                            Button("Join") {
                                                team.joinTeam(teamCode: enteredCode)
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
                        Section(header: Text("Your Team")) {
                            if(team.students.count == 0) {
                                HStack {
                                    Spacer()
                                    Text("Tell your students to join with the code!").foregroundColor(Color.gray)
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
                        
                        Section(header: Text("Team Info")) {
                            HStack {
                                Text("Team Code")
                                Spacer()
                                Text(team.teamCode).foregroundColor(Color.gray)
                            }
                            HStack {
                                Text("Founder")
                                Spacer()
                                Text(team.admins.first(where: { $0.founder })?.name ?? "No Founder").foregroundColor(Color.gray)
                            }
                        }
                        
                        Section() {
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
                    }
                    Section() {
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
