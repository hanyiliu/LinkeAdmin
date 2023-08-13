//
//  HelpView.swift
//  Linke for Admins
//
//  Created by Hanyi Liu on 8/12/23.
//

import SwiftUI


struct HelpView: View {
    @StateObject var viewRouter: ViewRouter
    @State private var selectedTab = 0
    
    @State var fromHome: Bool
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    private let dotAppearance = UIPageControl.appearance()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Help1(mode: colorScheme, fromHome: fromHome)
                .tag(0)
            Help2(mode: colorScheme, fromHome: fromHome)
                .tag(1)
            Help3(mode: colorScheme, fromHome: fromHome)
                .tag(2)
            Help4(mode: colorScheme, fromHome: fromHome)
                .tag(3)
            Help5(mode: colorScheme, fromHome: fromHome)
                .tag(4)
            Help6(mode: colorScheme, fromHome: fromHome)
                .tag(5)
            Help7(mode: colorScheme, fromHome: fromHome, viewRouter: viewRouter)
                .tag(6)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onAppear {
            dotAppearance.currentPageIndicatorTintColor = .black
            dotAppearance.pageIndicatorTintColor = .gray
        }
    }
}

struct Help1: View {
    let mode: ColorScheme
    let fromHome: Bool
    
    var body: some View {
        VStack {
            if !fromHome {
                Spacer()
                    .frame(height: UIScreen.main.bounds.size.height/6)
            }
            Text("Once you're in a team, there will be two codes:")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.horizontal, UIScreen.main.bounds.size.width/20)
            Image(mode == .dark ? "Help1-dark" : "Help1") // Replace with your image names
                .resizable()
                .scaledToFit()
                .padding()
                .cornerRadius(30)
                .background(.gray.opacity(0.10))
                .cornerRadius(10)
                .padding()
                .frame(width: UIScreen.main.bounds.size.width/1.25)
            Text("Students and Admins will join accordingly using them.")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.horizontal, UIScreen.main.bounds.size.width/20)
        }
    }
}

struct Help2: View {
    let mode: ColorScheme
    let fromHome: Bool
    
    var body: some View {
        VStack {
            if !fromHome {
                Spacer()
                    .frame(height: UIScreen.main.bounds.size.height/6)
            }
            Text("If you're joining a team as an admin, click:")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.horizontal, UIScreen.main.bounds.size.width/20)
            Image(mode == .dark ? "Help2-1-dark" : "Help2-1") // Replace with your image names
                .resizable()
                .scaledToFit()
                .padding()
                .cornerRadius(30)
                .background(.gray.opacity(0.10))
                .cornerRadius(10)
                .padding()
                .frame(width: UIScreen.main.bounds.size.width/1.25)
            Text("For your students, once they open the \"Your Team\" tab on Linke, they will be able to join your team.")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.horizontal, UIScreen.main.bounds.size.width/20)
            Image(mode == .dark ? "Help2-2-dark" : "Help2-2") // Replace with your image names
                .resizable()
                .scaledToFit()
                .padding()
                .cornerRadius(30)
                .background(.gray.opacity(0.10))
                .cornerRadius(10)
                .padding()
                .frame(width: UIScreen.main.bounds.size.width/1.25)
        }
    }
}

struct Help3: View {
    let mode: ColorScheme
    let fromHome: Bool
    
    var body: some View {
        VStack {
            if !fromHome {
                Spacer()
                    .frame(height: UIScreen.main.bounds.size.height/6)
            }
            Text("After students have joined, you can view all their assignments in their respective tabs.")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.horizontal, UIScreen.main.bounds.size.width/20)
            Image(mode == .dark ? "Help3-dark" : "Help3") // Replace with your image names
                .resizable()
                .scaledToFit()
                .padding()
                .cornerRadius(30)
                .background(.gray.opacity(0.10))
                .cornerRadius(10)
                .padding()
                .frame(width: UIScreen.main.bounds.size.width/1.25)
        }
    }
}

struct Help4: View {
    let mode: ColorScheme
    let fromHome: Bool
    
    var body: some View {
        VStack {
            if !fromHome {
                Spacer()
                    .frame(height: UIScreen.main.bounds.size.height/6)
            }
            Text("Students will have four different statuses:")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.horizontal, UIScreen.main.bounds.size.width/20)
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.red)
                    .frame(width: UIScreen.main.bounds.size.width/12, alignment: .leading)
                Spacer().frame(width: UIScreen.main.bounds.size.width/15, alignment: .leading)
                Text("Has missing assignments")
                    .multilineTextAlignment(.leading)
            }
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.yellow)
                    .frame(width: UIScreen.main.bounds.size.width/12, alignment: .leading)
                Spacer().frame(width: UIScreen.main.bounds.size.width/15, alignment: .leading)
                Text("Has upcoming assignments due within two days")
                    .multilineTextAlignment(.leading)
            }
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.green)
                    .frame(width: UIScreen.main.bounds.size.width/12, alignment: .leading)
                Spacer().frame(width: UIScreen.main.bounds.size.width/15, alignment: .leading)
                Text("Have finished all due assignments")
                    .multilineTextAlignment(.leading)
            }
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .frame(width: UIScreen.main.bounds.size.width/12, alignment: .leading)
                Spacer().frame(width: UIScreen.main.bounds.size.width/15, alignment: .leading)
                Text("Have not updated in over a week")
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct Help5: View {
    let mode: ColorScheme
    let fromHome: Bool
    
    var body: some View {
        VStack {
            if !fromHome {
                Spacer()
                    .frame(height: UIScreen.main.bounds.size.height/6)
            }
            Text("If you’re a founder, you can create groups of players and admins, which will only be visible to the admins you add to that group.")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.horizontal, UIScreen.main.bounds.size.width/20)
            Image(mode == .dark ? "Help5-dark" : "Help5") // Replace with your image names
                .resizable()
                .scaledToFit()
                .padding()
                .cornerRadius(30)
                .background(.gray.opacity(0.10))
                .cornerRadius(10)
                .padding()
                .frame(width: UIScreen.main.bounds.size.width/1.25)
        }
    }
}

struct Help6: View {
    let mode: ColorScheme
    let fromHome: Bool
    
    var body: some View {
        VStack {
            if !fromHome {
                Spacer()
                    .frame(height: UIScreen.main.bounds.size.height/6)
            }
            Text("You can also view students sorted by their teachers:")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.horizontal, UIScreen.main.bounds.size.width/20)
            Image(mode == .dark ? "Help6-dark" : "Help6") // Replace with your image names
                .resizable()
                .scaledToFit()
                .padding()
                .cornerRadius(30)
                .background(.gray.opacity(0.10))
                .cornerRadius(10)
                .padding()
                .frame(width: UIScreen.main.bounds.size.width/1.25)
        }
    }
}

struct Help7: View {
    let mode: ColorScheme
    let fromHome: Bool
    @StateObject var viewRouter: ViewRouter
    @Environment(\.presentationMode) var presentationMode
    @State var checked = false
     
    var body: some View {
        VStack {
            if !fromHome {
                Spacer()
                    .frame(height: UIScreen.main.bounds.size.height/6)
            }
            Text("You're all set!")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.horizontal, UIScreen.main.bounds.size.width/20)
            if(fromHome) {
                Button("Continue") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .tint(.blue)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            } else {
                Button("Continue") {
                    viewRouter.currentPage = .home
                    if(checked) {
                        UpdateValue.saveToLocal(key: "SHOW_HELP", value: false)
                    } else {
                        UpdateValue.saveToLocal(key: "SHOW_HELP", value: true)
                    }
                }
                .tint(.blue)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                
                Toggle(isOn: $checked) {
                    Text("Don't show this again")
                }
                .toggleStyle(CheckboxStyle())
            }
        }
    }
}


struct CheckboxStyle: ToggleStyle {

    func makeBody(configuration: Self.Configuration) -> some View {

        return HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle" : "circle")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .font(.system(size: 20, weight: .regular, design: .default))
                configuration.label
        }
        .onTapGesture { configuration.isOn.toggle() }

    }
}

