//
//  SettingsView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 8/16/23.
//

import Foundation
import SwiftUI
import GoogleSignIn
import FirebaseFirestore

struct SettingsView: View {
    
    @StateObject var viewRouter: ViewRouter
    @StateObject var team: Team
    @StateObject var admin: Admin
    
    @State private var deleteAccountAlert = false
    
    var body: some View {
        Form {
            Section("Your Account") {
                Button("Delete Account") {
                    deleteAccountAlert = true
                }
                .foregroundColor(.red)
                .alert(isPresented: $deleteAccountAlert) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? If you're the founder of your team, it will also be deleted."),
                        primaryButton: .destructive(Text("Delete"), action: {
                            print(admin.id)
                            
                            if(team.teamAdminCode.count != 0) {
                                if admin.founder {
                                    team.deleteTeam(currentAdmin: admin)
                                } else {
                                    team.leaveTeam()
                                }
                            }
                            
                            print("Team part finished.")
                            admin.delete()
                            
                            GIDSignIn.sharedInstance.signOut()
                            UpdateValue.saveToLocal(key: "SHOW_HELP", value: true)
                            viewRouter.currentPage = .googleSignIn
                        }),
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    
}
