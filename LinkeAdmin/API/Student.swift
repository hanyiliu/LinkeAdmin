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
    
    var hasMissingAssignments: Bool {
        classrooms.contains { classroom in
            classroom.missingAssignments.contains { assignment in
                assignment.dueDate != nil && assignment.dueDate! < Date()
            }
        }
    }
    
    var hasUpcomingAssignments: Bool {
        classrooms.contains { classroom in
            classroom.upcomingAssignments.contains { assignment in
                if let dueDate = assignment.dueDate {
                    let twoDaysFromNow = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
                    return dueDate >= Date() && dueDate <= twoDaysFromNow
                }
                return false
            }
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
