//
//  ContentView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    
    @StateObject var viewRouter: ViewRouter
    
    var body: some View {
        switch viewRouter.currentPage {
        case .loading:
            LoadingView()
        case .googleSignIn:
            GoogleSignInView(viewRouter: viewRouter)
        case .home:
            
            let team = Team()
            let admin = Admin(name: GIDSignIn.sharedInstance.currentUser?.profile?.name ?? "",
                             id: GIDSignIn.sharedInstance.currentUser?.userID ?? "",
                             email: GIDSignIn.sharedInstance.currentUser?.profile?.email ?? "")
            HomeView(viewRouter: viewRouter, team: team, admin: admin)
                
        }
    }

}

enum Page {
    case loading
    case googleSignIn
    case home
}
