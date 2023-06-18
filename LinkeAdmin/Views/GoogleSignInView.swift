//
//  GoogleSignInView.swift
//  Linker
//
//  Created by Hanyi Liu on 12/6/22.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct GoogleSignInView: View {
    
    @StateObject var viewRouter: ViewRouter
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    let clientID = "102247840613-h0icqnch0ugvb4efp7vjob0d5ljkg90s.apps.googleusercontent.com"

    var body: some View {
        
        
        VStack {
            Spacer()
            Image("Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.size.width/3)
            Spacer().frame(height: UIScreen.main.bounds.size.height/10)
            Text("Welcome to Linke for Admins!").font(.title)
            Text("Please sign in:")
            if(colorScheme == .light) {
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .standard, state: .normal), action: prepareSignIn)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(Color.gray, lineWidth: 1)
                    )
            } else {
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .standard, state: .normal), action: prepareSignIn)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(Color.gray, lineWidth: 1)
                    )
            }
            Spacer()
        }
        .padding()
    }
    
    
    func prepareSignIn(){
        let signInConfig = GIDConfiguration(clientID: clientID)
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("There is no root view controller!")
            return
        }
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: rootViewController) {
            user, error in
            
            if(error == nil) {
                viewRouter.currentPage = .loading
            }
        }
    }
}

