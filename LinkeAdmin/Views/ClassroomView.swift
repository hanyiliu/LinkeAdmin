//
//  ClassroomView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/4/23.
//

import Foundation
import SwiftUI

struct ClassroomView: View {
    @StateObject var classroom: Classroom
    
    var body: some View {
        List {
            Section() {
                HStack{
                    Text("Teacher")
                    Spacer()
                    Text(classroom.teacherName).foregroundColor(Color.gray)
                }
            }
            Section(header: Text("Upcoming Assignments")) {
                ForEach(classroom.upcomingAssignments) { assign in
                    HStack {
                        Text(assign.name)
                        Spacer()
                        Text(assign.formattedDueDate()).foregroundColor(Color.gray)
                    }
                }
            }
            
            Section(header: Text("Missing Assignments")) {
                ForEach(classroom.missingAssignments) { assign in
                    HStack {
                        Text(assign.name)
                        Spacer()
                        Text(assign.formattedDueDate()).foregroundColor(Color.red)
                    }
                }
            }
            
            Section(header: Text("In Progress")) {
                ForEach(classroom.inProgressAssignments) { assign in
                    HStack {
                        Text(assign.name)
                        Spacer()
                        Text(assign.formattedDueDate()).foregroundColor(Color.gray)
                    }
                }
            }
            
            Section(header: Text("Completed")) {
                ForEach(classroom.completedAssignments) { assign in
                    HStack {
                        Text(assign.name)
                        Spacer()
                        Text(assign.formattedDueDate()).foregroundColor(Color.gray)
                    }
                }
            }
        }
        .navigationBarTitle(Text(classroom.name))
    }
    
    
}

struct AssignmentRow: View {
    let assign: Assignment
    
    var body: some View {
            Text(assign.name)

        
    }
    

}

