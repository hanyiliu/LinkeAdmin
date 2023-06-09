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
    
    init(name: String, id: String, dueDate: Date?, status: AssignmentStatus) {
        self.name = name
        self.id = id
        if let dueDate = dueDate {
            self.dueDate = Assignment.toLocalTime(gmtDate: dueDate)
        }
        self.status = status
    }
    
    ///Return Date in user's local time, converts form GMT.
    static func toLocalTime(gmtDate: Date) -> Date {

        let timeZone = TimeZone.current
        let secondsFromGMT = timeZone.secondsFromGMT(for: gmtDate)
        return gmtDate.addingTimeInterval(TimeInterval(secondsFromGMT))
    }
    
    ///Return dueDate in a readable String format.
    func formattedDueDate() -> String {
        guard let dueDate = dueDate else { return "No Due Date" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/d hh:mm a"
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
