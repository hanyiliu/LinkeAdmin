//
//  Assignment.swift
//  LinkeAdmin
//
//  Created by Hanyi Liu on 6/2/23.
//

import Foundation

class Assignment: Identifiable {
    var name: String
    var id: String
    var dueDate: Date?

    var status: AssignmentStatus

    init(assignmentDict: [String: Any]) {
        id = assignmentDict["id"] as? String ?? ""
        name = assignmentDict["name"] as? String ?? ""
        
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
            
            if let dueTimeDict = assignmentDict["due_time"] as? [String: Int],
               let hour = dueTimeDict["hour"],
               let minute = dueTimeDict["minute"]
            {
                dateComponents.hour = hour
                dateComponents.minute = minute
                dueDate = calendar.date(from: dateComponents)
                dueDate = Assignment.toLocalTime(gmtDate: dueDate!)
            } else {
                dateComponents.hour = 23
                dateComponents.minute = 59
                dueDate = calendar.date(from: dateComponents)
            }
            
            
        }
        self.dueDate = dueDate
        
        let statusID = assignmentDict["status"] as? Int ?? 0
        var status: AssignmentStatus = .inProgress
        
        if(statusID == 1) {
            status = .completedClassroom
        }// else if(statusID == 2) {
//            //status = .completedReminders TODO: implement feature to toggle this
//            status = .inProgress
//        }
        self.status = status
    }
    
    ///Return Date in user's local time, converts form GMT.
    static func toLocalTime(gmtDate: Date) -> Date {

        let timeZone = TimeZone.current
        let secondsFromGMT = timeZone.secondsFromGMT(for: gmtDate)
        return gmtDate.addingTimeInterval(TimeInterval(secondsFromGMT))
    }
    
    /// Return dueDate in a readable String format.
    func formattedDueDate() -> String {
        guard let dueDate = dueDate else { return "No Due Date" }
        let dateFormatter = DateFormatter()
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let dueYear = Calendar.current.component(.year, from: dueDate)
        
        if currentYear != dueYear {
            dateFormatter.dateFormat = "M/d/yy h:mm a"
        } else {
            dateFormatter.dateFormat = "M/d h:mm a"
        }
        
        return dateFormatter.string(from: dueDate)
    }
    
}

///Types: inProgress. completedClassroom (will override completedReminders), completedReminders
enum AssignmentStatus : CustomStringConvertible, Identifiable, Encodable, Decodable {
    case inProgress
    case completedClassroom
    case completedReminders
    
    var count: Int {
        return 3
    }
    
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .inProgress: return "In Progress"
        case .completedClassroom: return "Completed in Classroom"
        case .completedReminders: return "Completed in Reminders"
            
        }
    }
    var id: String {
        switch self {
        case .inProgress: return "inProgress"
        case .completedClassroom: return "completedClassroom"
        case .completedReminders: return "completedReminders"
        }
    }
}
