//
//  StudentView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import Foundation
import SwiftUI

struct StudentView: View {
    @StateObject var student: Student
    var body: some View {
        Form {
            Section(header: Text("Upcoming Assignments")) {
                ForEach(student.classrooms.filter { !$0.hiddenByStudent }
                                         .flatMap { $0.upcomingAssignments }
                                         .sorted(by: { $0.dueDate ?? Date() < $1.dueDate ?? Date() }), id: \.id) { assign in
                    HStack {
                        Text(assign.name)
                        Spacer()
                        Text(assign.formattedDueDate()).foregroundColor(Color.gray)
                    }
                }
            }

            Section(header: Text("Missing Assignments")) {
                ForEach(student.classrooms.filter { !$0.hiddenByStudent }
                                         .flatMap { $0.missingAssignments }
                                         .sorted(by: { $0.dueDate ?? Date() < $1.dueDate ?? Date() }), id: \.id) { assign in
                    HStack {
                        Text(assign.name)
                        Spacer()
                        Text(assign.formattedDueDate()).foregroundColor(Color.red)
                    }
                }
            }

            
            Section(header: Text("Classrooms")) {
                ForEach(student.classrooms.filter { !$0.hiddenByStudent }) { classroom in
                    NavigationLink(destination: ClassroomView(classroom: classroom)) {
                        Text(classroom.name)
                    }
                }

                ForEach(student.classrooms.filter { $0.hiddenByStudent }) { classroom in
                    NavigationLink(destination: ClassroomView(classroom: classroom)) {
                        Text(classroom.name)
                            .foregroundColor(.gray) // Set text color to gray
                    }
                }
            }
            
            Section() {
                HStack {
                    Text("Last Updated")
                    Spacer()
                    Text(student.formattedUpdateDate()).foregroundColor(Color.gray)
                }
            }
        }.navigationBarTitle(Text(student.name))
    }
}

