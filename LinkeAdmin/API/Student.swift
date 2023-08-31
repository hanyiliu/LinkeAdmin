//
//  Student.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/1/23.
//

import Foundation
import Firebase

class Student: User {
    
    var classrooms: [Classroom]
    var lastUpdated: Date
    
    var status: StudentStatus {
        if lastUpdated < Calendar.current.date(byAdding: .day, value: -7, to: Date())! {
            return .outdated(lastUpdated: lastUpdated)
        } else if missingAssignmentsCount != 0 {
            return .hasMissingAssignments(count: missingAssignmentsCount)
        } else if upcomingAssignmentsCount != 0 {
            return .hasUpcomingAssignments(count: upcomingAssignmentsCount)
        } else {
            return .upToDate
        }
    }
    
    var missingAssignmentsCount: Int {
        return classrooms.reduce(0) { result, classroom in
            return result + classroom.missingAssignments.filter { assignment in
                assignment.dueDate != nil && assignment.dueDate! < Date()
            }.count
        }
    }

    var upcomingAssignmentsCount: Int {
        return classrooms.reduce(0) { result, classroom in
            return result + classroom.upcomingAssignments.filter { assignment in
                if let dueDate = assignment.dueDate {
                    let twoDaysFromNow = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
                    return dueDate >= Date() && dueDate <= twoDaysFromNow
                }
                return false
            }.count
        }
    }

    init(name: String, id: String, email: String, classrooms: [Classroom], lastUpdated: Date) {
        self.classrooms = classrooms
        self.lastUpdated = lastUpdated
        super.init(name: name, id: id, email: email)
    }
    
    init(studentDictionary: [String: Any]) {
        let name = studentDictionary["name"] as? String ?? ""
        let id = studentDictionary["id"] as? String ?? ""
        let email = studentDictionary["email"] as? String ?? ""
        
        
        let classroomArray = studentDictionary["classroom"] as? [[String: Any]] ?? []
        let classrooms = classroomArray.map { classroomDict -> Classroom in
            return Classroom(classroomDict: classroomDict)
        }
        
        self.lastUpdated = (studentDictionary["last_updated"] as! Timestamp).dateValue()
        self.classrooms = classrooms
        
        super.init(name: name, id: id, email: email)
    }
    
    /// Return dueDate in a readable String format.
    func formattedUpdateDate() -> String {
        let dateFormatter = DateFormatter()
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let dueYear = Calendar.current.component(.year, from: lastUpdated)
        
        if currentYear != dueYear {
            dateFormatter.dateFormat = "M/d/yy h:mm a"
        } else {
            dateFormatter.dateFormat = "M/d h:mm a"
        }
        
        return dateFormatter.string(from: lastUpdated)
    }
}

enum StudentStatus: Equatable, Comparable {
    case outdated(lastUpdated: Date)
    case hasMissingAssignments(count: Int)
    case hasUpcomingAssignments(count: Int)
    case upToDate
    
    var sortOrder: Int {
        switch self {
        case .outdated:
            return 0
        case .hasMissingAssignments:
            return 1
        case .hasUpcomingAssignments:
            return 2
        case .upToDate:
            return 3
        }
    }
    
    static func < (lhs: StudentStatus, rhs: StudentStatus) -> Bool {
        // First, compare the sortOrder
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        
        // For the same sortOrder, apply specific comparisons
        switch (lhs, rhs) {
        case (.outdated(let lastUpdated1), .outdated(let lastUpdated2)):
            return lastUpdated1 < lastUpdated2
        case (.hasMissingAssignments(let count1), .hasMissingAssignments(let count2)):
            return count1 > count2
        case (.hasUpcomingAssignments(let count1), .hasUpcomingAssignments(let count2)):
            return count1 > count2
        case (.upToDate, .upToDate):
            return false
        default:
            // For different cases, use default comparison
            return lhs.sortOrder < rhs.sortOrder
        }
    }
}
