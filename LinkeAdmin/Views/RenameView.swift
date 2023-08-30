//
//  RenameView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 8/30/23.
//

import SwiftUI

struct RenameView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State var title: String
    @Binding var currentValue: String
    @State private var newValue = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(title)) {
                    HStack {
                        TextField(currentValue, text: $newValue)
                        if !newValue.isEmpty {
                            Button(action: {
                                newValue = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.gray.opacity(0.6))
                                    .padding(.leading, 4)
                            }
                        }
                    }
                }
            }
        }.navigationBarTitle(title, displayMode: .inline)
        .onDisappear {
            if !newValue.isEmpty {
                currentValue = newValue
            }
        }
        .onAppear {
            newValue = currentValue
        }
    }
}

