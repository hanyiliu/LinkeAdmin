//
//  GroupView.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/16/23.
//

import Foundation
import SwiftUI

struct GroupView: View {
    @StateObject var group: Group
    
    @State private var isShowingAddStudentsSheet = false
    @State private var isShowingAddAdminsSheet = false
    @State private var selectedStudents: Set<Student> = []
    @State private var selectedAdmins: Set<Admin> = []

    var body: some View {
        Form {
            Section(header: Text("Students")) {
                ForEach(group.students) { student in
                    NavigationLink(destination: StudentView(student: student)) {
                        Text(student.name)
                    }
                }
                .onDelete(perform: group.deleteStudent)
                Button("Add Students") {
                    isShowingAddStudentsSheet = true
                }
            }

            Section(header: Text("Admins")) {
                ForEach(group.admins) { admin in
                    Text(admin.name)
                }
                .onDelete(perform: group.deleteAdmin)
                Button("Add Admins") {
                    isShowingAddAdminsSheet = true
                }
            }
        }
        .sheet(isPresented: $isShowingAddStudentsSheet) {
            AddStudentsSheet(group: group, selectedStudents: $selectedStudents)
        }
        .sheet(isPresented: $isShowingAddAdminsSheet) {
            AddAdminsSheet(group: group, selectedAdmins: $selectedAdmins)
        }
        .navigationTitle(group.name)
    }
}


struct AddStudentsSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var group: Group
    @Binding var selectedStudents: Set<Student>
    @State private var availableStudents: [Student]
    
    init(group: Group, selectedStudents: Binding<Set<Student>>) {
        self.group = group
        self._selectedStudents = selectedStudents
        self._availableStudents = State(initialValue: group.team.students.filter { !group.students.contains($0) })
    }
    
    var body: some View {
        VStack {
            List(availableStudents) { student in
                HStack {
                    Text(student.name)
                    Spacer()
                    if selectedStudents.contains(student) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleSelection(student: student)
                }
            }
            
            Button("Add Students") {
                addSelectedStudents()
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .navigationTitle("Add Students")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func toggleSelection(student: Student) {
        if selectedStudents.contains(student) {
            selectedStudents.remove(student)
        } else {
            selectedStudents.insert(student)
        }
    }
    
    private func addSelectedStudents() {
        for student in selectedStudents {
            group.addStudent(student: student)
        }
    }
}

struct AddAdminsSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var group: Group
    @Binding var selectedAdmins: Set<Admin>
    @State private var availableAdmins: [Admin]
    
    init(group: Group, selectedAdmins: Binding<Set<Admin>>) {
        self.group = group
        self._selectedAdmins = selectedAdmins
        self._availableAdmins = State(initialValue: group.team.admins.filter { !group.admins.contains($0) })
    }
    
    var body: some View {
        VStack {
            List(availableAdmins) { admin in
                HStack {
                    Text(admin.name)
                    Spacer()
                    if selectedAdmins.contains(admin) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleSelection(admin: admin)
                }
            }
            
            Button("Add Admins") {
                addSelectedAdmins()
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .navigationTitle("Add Admins")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func toggleSelection(admin: Admin) {
        if selectedAdmins.contains(admin) {
            selectedAdmins.remove(admin)
        } else {
            selectedAdmins.insert(admin)
        }
    }
    
    private func addSelectedAdmins() {
        for admin in selectedAdmins {
            group.addAdmin(admin: admin)
        }
    }
}
