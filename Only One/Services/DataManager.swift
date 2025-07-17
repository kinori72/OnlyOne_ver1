import Foundation

class DataManager {
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Events
    func saveEvents(_ events: [Event]) {
        if let encoded = try? JSONEncoder().encode(events) {
            userDefaults.set(encoded, forKey: "events")
        }
    }
    
    func loadEvents() -> [Event] {
        if let data = userDefaults.data(forKey: "events"),
           let events = try? JSONDecoder().decode([Event].self, from: data) {
            return events
        }
        return []
    }
    
    // MARK: - Tasks
    func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: "tasks")
        }
    }
    
    func loadTasks() -> [Task] {
        if let data = userDefaults.data(forKey: "tasks"),
           let tasks = try? JSONDecoder().decode([Task].self, from: data) {
            return tasks
        }
        return []
    }
    
    // MARK: - Shifts
    func saveShifts(_ shifts: [Shift]) {
        if let encoded = try? JSONEncoder().encode(shifts) {
            userDefaults.set(encoded, forKey: "shifts")
        }
    }
    
    func loadShifts() -> [Shift] {
        if let data = userDefaults.data(forKey: "shifts"),
           let shifts = try? JSONDecoder().decode([Shift].self, from: data) {
            return shifts
        }
        return []
    }
    
    // MARK: - Courses
    func saveCourses(_ courses: [Course]) {
        if let encoded = try? JSONEncoder().encode(courses) {
            userDefaults.set(encoded, forKey: "courses")
        }
    }
    
    func loadCourses() -> [Course] {
        if let data = userDefaults.data(forKey: "courses"),
           let courses = try? JSONDecoder().decode([Course].self, from: data) {
            return courses
        }
        return []
    }
}
