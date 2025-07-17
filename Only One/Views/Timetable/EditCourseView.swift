import SwiftUI

struct EditCourseView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showSaturday") private var showSaturday = false
    
    let course: Course
    
    @State private var title: String
    @State private var professor: String
    @State private var room: String
    @State private var selectedWeekday: String
    @State private var selectedPeriod: Int
    @State private var selectedColor: CourseColor
    @State private var notes: String
    @State private var selectedYear: Int
    @State private var selectedSemester: Semester
    
    private let weekdays = ["月", "火", "水", "木", "金"]
    private let weekdaysWithSaturday = ["月", "火", "水", "木", "金", "土"]
    
    private var displayWeekdays: [String] {
        showSaturday ? weekdaysWithSaturday : weekdays
    }
    
    init(course: Course) {
        self.course = course
        self._title = State(initialValue: course.title)
        self._professor = State(initialValue: course.professor)
        self._room = State(initialValue: course.room)
        self._selectedWeekday = State(initialValue: course.weekday)
        self._selectedPeriod = State(initialValue: course.period)
        self._selectedColor = State(initialValue: course.color)
        self._notes = State(initialValue: course.notes)
        self._selectedYear = State(initialValue: course.year)
        self._selectedSemester = State(initialValue: course.semester)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("学期情報")) {
                    Stepper("年度: \(selectedYear)", value: $selectedYear, in: 2020...2030)
                    
                    Picker("学期", selection: $selectedSemester) {
                        ForEach(Semester.allCases, id: \.self) { semester in
                            Text(semester.displayName).tag(semester)
                        }
                    }
                }
                
                Section(header: Text("基本情報")) {
                    TextField("授業名", text: $title)
                    TextField("教授名", text: $professor)
                    TextField("教室", text: $room)
                }
                
                Section(header: Text("時間")) {
                    Picker("曜日", selection: $selectedWeekday) {
                        ForEach(displayWeekdays, id: \.self) { weekday in
                            Text(weekday).tag(weekday)
                        }
                    }
                    
                    Picker("時限", selection: $selectedPeriod) {
                        ForEach(1...6, id: \.self) { period in
                            Text("\(period)限").tag(period)
                        }
                    }
                    
                    Picker("色", selection: $selectedColor) {
                        ForEach(CourseColor.allCases, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 20, height: 20)
                                Text(color.displayName)
                            }
                            .tag(color)
                        }
                    }
                }
                
                Section(header: Text("詳細")) {
                    TextField("メモ（任意）", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
                
                Section {
                    Button("授業を削除", role: .destructive) {
                        deleteCourse()
                    }
                }
            }
            .navigationTitle("授業を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        updateCourse()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func updateCourse() {
        var updatedCourse = course
        updatedCourse.title = title
        updatedCourse.professor = professor
        updatedCourse.room = room
        updatedCourse.weekday = selectedWeekday
        updatedCourse.period = selectedPeriod
        updatedCourse.color = selectedColor
        updatedCourse.notes = notes
        updatedCourse.year = selectedYear
        updatedCourse.semester = selectedSemester
        
        appState.updateCourse(updatedCourse)
        dismiss()
    }
    
    private func deleteCourse() {
        appState.deleteCourse(course)
        dismiss()
    }
}

#Preview {
    EditCourseView(course: Course(title: "数学", weekday: "月", period: 1, year: 2025, semester: .first))
        .environmentObject(AppState())
}
