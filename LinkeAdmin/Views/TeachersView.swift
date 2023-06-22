//
//  TeachersView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/20/23.
//

import Foundation
import SwiftUI

struct TeachersView: View {
    @StateObject var team: Team
    
    @State private var selectedTeacher: String?
    @State private var isDropdownVisible = false
    @State var teachersByStudentCount: [(String, Int, [(Student, String)])]
    
    var body: some View {
        Form {
            Section(header: Text("Teachers")) {
                ForEach(teachersByStudentCount, id: \.0) { teacher, studentCount, studentInfo in
                    HStack {
                        Text(teacher)
                        Spacer()
                        Text("\(studentCount) students").foregroundColor(Color.gray)
                        if isDropdownVisible && selectedTeacher == teacher {
                            Image(systemName: "chevron.up").foregroundColor(Color.gray)
                        
                        } else {
                            Image(systemName: "chevron.down").foregroundColor(Color.gray)
                        }
                            
                    }
                    .onTapGesture {
                        if selectedTeacher == teacher {
                            // Close the dropdown menu if the same teacher is tapped again
                            isDropdownVisible.toggle()
                        } else {
                            // Show the dropdown menu for the selected teacher
                            selectedTeacher = teacher
                            isDropdownVisible = true
                        }
                    }
                    

                    if isDropdownVisible && selectedTeacher == teacher {
                        dropdownMenuView(studentInfo: studentInfo)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func dropdownMenuView(studentInfo: [(Student, String)]) -> some View {
        let identifiers = studentInfo.map { "\($0.0.id)-\($0.1)" }
        
        VStack(alignment: .leading, spacing: 8) {
            ForEach(studentInfo.indices, id: \.self) { index in
                let student = studentInfo[index].0
                let className = studentInfo[index].1
                let identifier = identifiers[index]
                
                HStack {
                    Text(student.name)
                        .font(.system(size: UIFont.systemFontSize))
                    Spacer()
                    Text(className)
                        .font(.system(size: UIFont.systemFontSize))
                        .foregroundColor(Color.gray)
                }
                .id(identifier)
            }
        }
    }

}
