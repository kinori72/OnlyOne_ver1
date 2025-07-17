import SwiftUI

struct AddCourseView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showSaturday") private var showSaturday = false
    
    let selectedYear: Int
    let selectedSemester: Semester
    
    @State private var title = ""
    @State private var professor = ""
    @State private var room = ""
    @State private var selectedWeekday = "月"
    @State private var selectedPeriod = 1
    @State private var selectedColor = CourseColor.blue
    @State private var notes = ""
    
    private let weekdays = ["月", "火", "水", "木", "金"]
    private let weekdaysWithSaturday = ["月", "火", "水", "木", "金", "土"]
    
    private var displayWeekdays: [String] {
        showSaturday ? weekdaysWithSaturday : weekdays
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("学期情報")) {
                    HStack {
                        Text("年度")
                        Spacer()
                        Text("\(selectedYear)年")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("学期")
                        Spacer()
                        Text(selectedSemester.displayName)
                            .foregroundColor(.secondary)
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
            }
            .navigationTitle("授業を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addCourse()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addCourse() {
        // 同じ時間に既に授業があるかチェック
        let existingCourse = appState.courses.first { course in
            course.year == selectedYear &&
            course.semester == selectedSemester &&
            course.weekday == selectedWeekday &&
            course.period == selectedPeriod
        }
        
        if existingCourse != nil {
            // エラー処理（既に授業が存在する）
            return
        }
        
        let course = Course(
            title: title,
            professor: professor,
            room: room,
            weekday: selectedWeekday,
            period: selectedPeriod,
            color: selectedColor,
            notes: notes,
            year: selectedYear,
            semester: selectedSemester
        )
        
        appState.addCourse(course)
        dismiss()
    }
}

#Preview {
    AddCourseView(selectedYear: 2025, selectedSemester: .first)
        .environmentObject(AppState())
}
