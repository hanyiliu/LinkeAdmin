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
    
    init(name: String, id: String, email: String, classrooms: [Classroom], lastUpdated: Date) {
        self.classrooms = classrooms
        self.lastUpdated = lastUpdated
        super.init(name: name, id: id, email: email)
    }
    
    init(studentDictionary: [String:Any]) {
        let name = studentDictionary["name"] as? String ?? ""
        let id = studentDictionary["id"] as? String ?? ""
        let email = studentDictionary["email"] as? String ?? ""
        
        
        let classroomArray = studentDictionary["classroom"] as? [[String: Any]] ?? []
        let classrooms = classroomArray.map { classroomDict -> Classroom in
            let classroomID = classroomDict["id"] as? String ?? ""
            let classroomName = classroomDict["name"] as? String ?? ""
            
            let assignmentArray = classroomDict["assignment"] as? [[String: Any]] ?? []
            let assignments = assignmentArray.map { assignmentDict -> Assignment in
                let assignmentID = assignmentDict["id"] as? String ?? ""
                let assignmentName = assignmentDict["name"] as? String ?? ""
                
                var dueDate: Date? = nil
                if let dueDateDict = assignmentDict["due_date"] as? [String: Int],
                   let day = dueDateDict["day"],
                   let month = dueDateDict["month"],
                   let year = dueDateDict["year"]
                {
                    let calendar = Calendar.current
                    var dateComponents = DateComponents()
                    dateComponents.day = day
                    dateComponents.month = month
                    dateComponents.year = year
                    dueDate = calendar.date(from: dateComponents)
                    if let dueTimeDict = assignmentDict["due_time"] as? [String: Int],
                       let hour = dueTimeDict["hour"],
                       let minute = dueTimeDict["minute"]
                    {
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        dueDate = calendar.date(from: dateComponents)
                    }
                }
                
                let statusID = assignmentDict["status"] as? Int ?? 0
                print(statusID)
                var status: AssignmentStatus = .inProgress
                
                if(statusID == 1) {
                    status = .completedClassroom
                } else if(statusID == 2) {
                    status = .completedReminders
                }
            
                return Assignment(name: assignmentName, id: assignmentID, dueDate: dueDate, status: status)
            }
            
            return Classroom(name: classroomName, id: classroomID, assignments: assignments)
        }
        
        self.lastUpdated = (studentDictionary["last_updated"] as! Timestamp).dateValue()
        self.classrooms = classrooms
        
        super.init(name: name, id: id, email: email)
    }
    
    func formattedUpdateDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/d hh:mm a"
        return dateFormatter.string(from: lastUpdated)
    }
}
