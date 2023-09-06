//
//  StatusItemView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 9/6/23.
//

import SwiftUI

struct StatusItemView: View {
    var symbol: String
    var color: Color
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: symbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.size.width/18, alignment: .leading)
                .foregroundColor(color)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(10)
    }
}

