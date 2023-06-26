//
//  Classroom.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/2/23.
//

import Foundation

class Classroom: Identifiable, ObservableObject {
    var name: String
    var id: String
    var assignments: [Assignment]
    
    var teacherID: String
    var teacherName: String
    
    ///Initialize Classroom, given classroom dictionary.
    init(classroomDict: [String: Any]) {
        id = classroomDict["id"] as? String ?? ""
        name = classroomDict["name"] as? String ?? ""
        teacherID = classroomDict["teacher_id"] as? String ?? ""
        teacherName = classroomDict["teacher_name"] as? String ?? ""
        
        let assignmentArray = classroomDict["assignment"] as? [[String: Any]] ?? []
        assignments = assignmentArray.map { assignmentDict -> Assignment in
            return Assignment(assignmentDict: assignmentDict)
        }
        
    }
    
    ///Return Upcoming assignments (due within 7 days).
    var upcomingAssignments: [Assignment] {
        let currentDate = Date()
        let calendar = Calendar.current
        let sevenDaysFromNow = calendar.date(byAdding: .day, value: 7, to: currentDate)!
        
        return assignments.filter { assign in
            if let dueDate = assign.dueDate {
                
                return assign.status == .inProgress && calendar.isDate(assign.dueDate!, inSameDayAs: sevenDaysFromNow) && dueDate > currentDate
            }
            return false
        }
    }
    
    ///Return Missing assignments.
    var missingAssignments: [Assignment] {
        let currentDate = Date()
        
        return assignments.filter { assign in
            if let dueDate = assign.dueDate {
                return assign.status == .inProgress && dueDate < currentDate
            }
            return false
        }
    }
    
    ///Return In Progress assignments.
    var inProgressAssignments: [Assignment] {
        return assignments.filter { assign in
            assign.status == .inProgress && !upcomingAssignments.contains { $0.id == assign.id } && !missingAssignments.contains { $0.id == assign.id }
        }
    }
    
    ///Return Completed assignments.
    var completedAssignments: [Assignment] {
        return assignments.filter { assign in
            assign.status == .completedClassroom || assign.status == .completedReminders
        }
    }
    
}
