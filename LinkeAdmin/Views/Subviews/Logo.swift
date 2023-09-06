//
//  Logo.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 9/6/23.
//

import SwiftUI

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
