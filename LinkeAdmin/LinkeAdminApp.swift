//
//  LinkeAdminApp.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import SwiftUI
import GoogleSignIn
import FirebaseCore

@main
struct LinkeAdminApp: App {
    @StateObject var viewRouter = ViewRouter()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewRouter: viewRouter)
            
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
            
                .onAppear {
                    
                    FirebaseApp.configure()
                    
                    //Check Google authentication.
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        
                        if error != nil || user == nil {
                            // Show the app's signed-out state.
                            print("User not previously logged in")
                            viewRouter.currentPage = .googleSignIn
                        } else {
                            // Show the app's signed-in state.
                            
                            print("User previously logged in")
                            viewRouter.currentPage = .loadingSignedIn
                        }
                    }

                }
            
        }
    }
    
    
    
}

struct UpdateValue: Any {
    static func saveToLocal(key: String, value: Bool) {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    static func saveToLocal(key: String, value: Bool?) {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    static func saveToLocal(key: String, value: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    static func saveToLocal(key: String, value: Int) {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    static func loadFromLocal(key: String, type: String) -> Any? {
        if let data = UserDefaults.standard.data(forKey: key) {
            switch(type) {
            case "String":
                if let decoded = try? JSONDecoder().decode(String.self, from: data
                ) {
                    return decoded
                } else {
                    return nil
                }
            case "Bool":
                if let decoded = try? JSONDecoder().decode(Bool.self, from: data
                ) {
                    return decoded
                } else {
                    return nil
                }
            case "Int":
                if let decoded = try? JSONDecoder().decode(Int.self, from: data
                ) {
                    return decoded
                } else {
                    return nil
                }
            default:
                return nil
                
            }
        } else {
            
            
            return nil
        }
    }
}
