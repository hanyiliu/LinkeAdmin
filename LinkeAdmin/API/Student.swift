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
    
    func formattedUpdateDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/d hh:mm a"
        return dateFormatter.string(from: lastUpdated)
    }

}
