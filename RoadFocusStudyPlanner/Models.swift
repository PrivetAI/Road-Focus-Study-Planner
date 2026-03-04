import SwiftUI
import Foundation

// MARK: - Color Theme
struct AppColors {
    static let gold = Color(red: 212/255, green: 160/255, blue: 23/255)
    static let lightGray = Color(red: 232/255, green: 232/255, blue: 232/255)
    static let darkGray = Color(red: 74/255, green: 74/255, blue: 74/255)
    static let white = Color.white
    
    static let subjectColors: [Color] = [
        Color(red: 212/255, green: 160/255, blue: 23/255),
        Color(red: 70/255, green: 130/255, blue: 180/255),
        Color(red: 60/255, green: 179/255, blue: 113/255),
        Color(red: 205/255, green: 92/255, blue: 92/255),
        Color(red: 147/255, green: 112/255, blue: 219/255),
        Color(red: 255/255, green: 165/255, blue: 0/255),
        Color(red: 0/255, green: 191/255, blue: 255/255),
        Color(red: 255/255, green: 105/255, blue: 180/255),
    ]
}

// MARK: - Schedule
struct ScheduleEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    var subject: String
    var dayOfWeek: Int // 0=Sun, 1=Mon...6=Sat
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var colorIndex: Int
    
    var startTimeString: String {
        String(format: "%d:%02d", startHour, startMinute)
    }
    var endTimeString: String {
        String(format: "%d:%02d", endHour, endMinute)
    }
}

// MARK: - Task
enum TaskPriority: String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: Color {
        switch self {
        case .high: return Color(red: 205/255, green: 92/255, blue: 92/255)
        case .medium: return AppColors.gold
        case .low: return Color(red: 60/255, green: 179/255, blue: 113/255)
        }
    }
}

enum TaskStatus: String, Codable, CaseIterable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case done = "Done"
}

struct StudyTask: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var subject: String
    var deadline: Date
    var priority: TaskPriority
    var status: TaskStatus
}

// MARK: - Note
struct StudyNote: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var body: String
    var subject: String
    var dateCreated: Date
}

// MARK: - Timer Session
struct TimerSession: Codable {
    var date: Date
    var durationMinutes: Double
    var subject: String
}

// MARK: - Subject
struct Subject: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var colorIndex: Int
}

// Day helper
let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
let fullDayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
