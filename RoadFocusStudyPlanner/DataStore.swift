import Foundation
import SwiftUI

class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @Published var subjects: [Subject] = [] {
        didSet { saveSubjects() }
    }
    @Published var scheduleEntries: [ScheduleEntry] = [] {
        didSet { saveSchedule() }
    }
    @Published var tasks: [StudyTask] = [] {
        didSet { saveTasks() }
    }
    @Published var notes: [StudyNote] = [] {
        didSet { saveNotes() }
    }
    @Published var timerSessions: [TimerSession] = [] {
        didSet { saveTimerSessions() }
    }
    
    private let subjectsKey = "rf_subjects"
    private let scheduleKey = "rf_schedule"
    private let tasksKey = "rf_tasks"
    private let notesKey = "rf_notes"
    private let sessionsKey = "rf_sessions"
    
    init() {
        loadAll()
    }
    
    // MARK: - Load
    func loadAll() {
        subjects = load(key: subjectsKey) ?? []
        scheduleEntries = load(key: scheduleKey) ?? []
        tasks = load(key: tasksKey) ?? []
        notes = load(key: notesKey) ?? []
        timerSessions = load(key: sessionsKey) ?? []
    }
    
    private func load<T: Decodable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Save
    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func saveSubjects() { save(subjects, key: subjectsKey) }
    func saveSchedule() { save(scheduleEntries, key: scheduleKey) }
    func saveTasks() { save(tasks, key: tasksKey) }
    func saveNotes() { save(notes, key: notesKey) }
    func saveTimerSessions() { save(timerSessions, key: sessionsKey) }
    
    // MARK: - Subject helpers
    func addSubject(name: String) {
        let colorIdx = subjects.count % AppColors.subjectColors.count
        subjects.append(Subject(name: name, colorIndex: colorIdx))
    }
    
    func colorForSubject(_ name: String) -> Color {
        if let s = subjects.first(where: { $0.name == name }) {
            return AppColors.subjectColors[s.colorIndex % AppColors.subjectColors.count]
        }
        return AppColors.gold
    }
    
    // MARK: - Stats helpers
    func sessionsThisWeek() -> [TimerSession] {
        let cal = Calendar.current
        let now = Date()
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start else { return [] }
        return timerSessions.filter { $0.date >= weekStart }
    }
    
    func sessionsThisMonth() -> [TimerSession] {
        let cal = Calendar.current
        let now = Date()
        guard let monthStart = cal.dateInterval(of: .month, for: now)?.start else { return [] }
        return timerSessions.filter { $0.date >= monthStart }
    }
    
    func totalHours(_ sessions: [TimerSession]) -> Double {
        sessions.reduce(0) { $0 + $1.durationMinutes } / 60.0
    }
    
    func hoursPerSubject(_ sessions: [TimerSession]) -> [(String, Double)] {
        var dict: [String: Double] = [:]
        for s in sessions {
            dict[s.subject, default: 0] += s.durationMinutes / 60.0
        }
        return dict.sorted { $0.value > $1.value }
    }
    
    func studyStreak() -> Int {
        let cal = Calendar.current
        var streak = 0
        var checkDate = Date()
        
        // Check if studied today
        let todaySessions = timerSessions.filter { cal.isDate($0.date, inSameDayAs: checkDate) }
        if todaySessions.isEmpty {
            checkDate = cal.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        while true {
            let daySessions = timerSessions.filter { cal.isDate($0.date, inSameDayAs: checkDate) }
            if daySessions.isEmpty { break }
            streak += 1
            checkDate = cal.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        return streak
    }
    
    func averageSessionLength() -> Double {
        guard !timerSessions.isEmpty else { return 0 }
        return timerSessions.reduce(0) { $0 + $1.durationMinutes } / Double(timerSessions.count)
    }
}
