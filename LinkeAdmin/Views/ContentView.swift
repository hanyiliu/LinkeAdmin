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
    
    @State var admin: Admin?
    @State var team: Team?
    
    var body: some View {
        switch viewRouter.currentPage {
        case .loading:
            LoadingView()
        case .googleSignIn:
            GoogleSignInView(viewRouter: viewRouter)
        case .loadingSignedIn:
            LoadingView().onAppear() {
                admin = Admin(name: GIDSignIn.sharedInstance.currentUser?.profile?.name ?? "",
                                      id: GIDSignIn.sharedInstance.currentUser?.userID ?? "",
                                      email: GIDSignIn.sharedInstance.currentUser?.profile?.email ?? "")
                team = Team(currentAdmin: admin!, viewRouter: viewRouter)
            }
        case .home:
            
            HomeView(viewRouter: viewRouter, team: team!, admin: admin!)
                
        }
    }

}

enum Page {
    case loading
    case googleSignIn
    case loadingSignedIn
    case home
}
