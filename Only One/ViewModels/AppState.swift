import Foundation
import Combine

class AppState: ObservableObject {
    @Published var events: [Event] = []
    @Published var tasks: [Task] = []
    @Published var shifts: [Shift] = []
    @Published var courses: [Course] = []
    @Published var selectedDate = Date()
    @Published var showingDayDetail = false
    
    private let dataManager = DataManager()
    
    init() {
        loadData()
        migrateCoursesIfNeeded() // NEW: 既存データの移行
    }
    
    func loadData() {
        events = dataManager.loadEvents()
        tasks = dataManager.loadTasks()
        shifts = dataManager.loadShifts()
        courses = dataManager.loadCourses()
    }
    
    // NEW: 既存の授業データに年・学期情報を追加
    private func migrateCoursesIfNeeded() {
        var needsMigration = false
        var updatedCourses: [Course] = []
        
        for course in courses {
            // 年・学期情報がない古いデータをチェック
            if course.year == 0 { // デフォルト値の場合
                var newCourse = course
                newCourse.year = Calendar.current.component(.year, from: Date())
                newCourse.semester = .first
                updatedCourses.append(newCourse)
                needsMigration = true
            } else {
                updatedCourses.append(course)
            }
        }
        
        if needsMigration {
            courses = updatedCourses
            dataManager.saveCourses(courses)
        }
    }
    
    // MARK: - Event Methods
    func addEvent(_ event: Event) {
        events.append(event)
        dataManager.saveEvents(events)
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            dataManager.saveEvents(events)
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        dataManager.saveEvents(events)
    }
    
    // MARK: - Task Methods
    func addTask(_ task: Task) {
        tasks.append(task)
        dataManager.saveTasks(tasks)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            dataManager.saveTasks(tasks)
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        dataManager.saveTasks(tasks)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            dataManager.saveTasks(tasks)
        }
    }
    
    // MARK: - Shift Methods
    func addShift(_ shift: Shift) {
        shifts.append(shift)
        dataManager.saveShifts(shifts)
    }
    
    func updateShift(_ shift: Shift) {
        if let index = shifts.firstIndex(where: { $0.id == shift.id }) {
            shifts[index] = shift
            dataManager.saveShifts(shifts)
        }
    }
    
    func deleteShift(_ shift: Shift) {
        shifts.removeAll { $0.id == shift.id }
        dataManager.saveShifts(shifts)
    }
    
    // MARK: - Course Methods
    func addCourse(_ course: Course) {
        courses.append(course)
        dataManager.saveCourses(courses)
    }
    
    func updateCourse(_ course: Course) {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index] = course
            dataManager.saveCourses(courses)
        }
    }
    
    func deleteCourse(_ course: Course) {
        courses.removeAll { $0.id == course.id }
        dataManager.saveCourses(courses)
    }
    
    // MARK: - Day Detail Methods
    func showDayDetail(for date: Date) {
        selectedDate = date
        showingDayDetail = true
    }
    
    func hideDayDetail() {
        showingDayDetail = false
    }
}
