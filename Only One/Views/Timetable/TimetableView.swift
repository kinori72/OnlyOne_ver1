import SwiftUI

struct TimetableView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("showSaturday") private var showSaturday = false
    @AppStorage("period1Start") private var period1Start = "09:00"
    @AppStorage("period1End") private var period1End = "10:30"
    @AppStorage("period2Start") private var period2Start = "10:40"
    @AppStorage("period2End") private var period2End = "12:10"
    @AppStorage("period3Start") private var period3Start = "13:00"
    @AppStorage("period3End") private var period3End = "14:30"
    @AppStorage("period4Start") private var period4Start = "14:40"
    @AppStorage("period4End") private var period4End = "16:10"
    @AppStorage("period5Start") private var period5Start = "16:20"
    @AppStorage("period5End") private var period5End = "17:50"
    @AppStorage("period6Start") private var period6Start = "18:00"
    @AppStorage("period6End") private var period6End = "19:30"
    
    @State private var showingAddCourse = false
    @State private var selectedCourse: Course?
    @State private var showingSettings = false
    @State private var currentYear: Int
    @State private var currentSemester: Semester = .first
    
    private let weekdays = ["月", "火", "水", "木", "金"]
    private let weekdaysWithSaturday = ["月", "火", "水", "木", "金", "土"]
    
    init() {
        let year = Calendar.current.component(.year, from: Date())
        self._currentYear = State(initialValue: year)
    }
    
    private var displayWeekdays: [String] {
        showSaturday ? weekdaysWithSaturday : weekdays
    }
    
    private var periodTimes: [(start: String, end: String)] {
        [
            (period1Start, period1End),
            (period2Start, period2End),
            (period3Start, period3End),
            (period4Start, period4End),
            (period5Start, period5End),
            (period6Start, period6End)
        ]
    }
    
    // 現在の年・学期の授業のみを表示
    private var currentCourses: [Course] {
        appState.courses.filter { course in
            course.year == currentYear && course.semester == currentSemester
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 年・学期選択
                VStack(spacing: 12) {
                    // 年選択
                    HStack {
                        Button(action: {
                            currentYear -= 1
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        Text("\(currentYear)年")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            currentYear += 1
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 学期選択
                    Picker("学期", selection: $currentSemester) {
                        ForEach(Semester.allCases, id: \.self) { semester in
                            Text(semester.displayName).tag(semester)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.top)
                
                Divider()
                
                // 時間割表
                GeometryReader { geometry in
                    ScrollView([.horizontal, .vertical]) {
                        LazyVGrid(columns: createColumns(width: geometry.size.width), spacing: 1) {
                            // ヘッダー行
                            Text("")
                                .font(.caption2)
                                .frame(width: cellWidth(for: geometry.size.width, isTimeColumn: true), height: 35)
                                .background(Color(.systemGray5))
                            
                            ForEach(displayWeekdays, id: \.self) { weekday in
                                Text(weekday)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: cellWidth(for: geometry.size.width, isTimeColumn: false), height: 35)
                                    .background(Color(.systemGray5))
                            }
                            
                            // 時限行
                            ForEach(0..<6, id: \.self) { period in
                                // 時限ラベル
                                VStack(spacing: 1) {
                                    Text("\(period + 1)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                    Text(periodTimes[period].start)
                                        .font(.system(size: 8))
                                        .foregroundColor(.secondary)
                                    Text("〜")
                                        .font(.system(size: 8))
                                        .foregroundColor(.secondary)
                                    Text(periodTimes[period].end)
                                        .font(.system(size: 8))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: cellWidth(for: geometry.size.width, isTimeColumn: true), height: 60)
                                .background(Color(.systemGray5))
                                
                                // 授業セル
                                ForEach(0..<displayWeekdays.count, id: \.self) { dayIndex in
                                    let course = findCourse(period: period + 1, weekday: displayWeekdays[dayIndex])
                                    
                                    CourseCell(
                                        course: course,
                                        onTap: { tappedCourse in
                                            if let tappedCourse = tappedCourse {
                                                selectedCourse = tappedCourse
                                            } else {
                                                showingAddCourse = true
                                            }
                                        }
                                    )
                                    .frame(width: cellWidth(for: geometry.size.width, isTimeColumn: false), height: 60)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("時間割")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCourse) {
            AddCourseView(selectedYear: currentYear, selectedSemester: currentSemester)
                .environmentObject(appState)
        }
        .sheet(item: $selectedCourse) { course in
            EditCourseView(course: course)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showingSettings) {
            TimetableSettingsView()
        }
    }
    
    private func createColumns(width: CGFloat) -> [GridItem] {
        let totalColumns = 1 + displayWeekdays.count
        return Array(repeating: GridItem(.fixed(cellWidth(for: width, isTimeColumn: false)), spacing: 1), count: totalColumns)
    }
    
    private func cellWidth(for screenWidth: CGFloat, isTimeColumn: Bool) -> CGFloat {
        let totalColumns = 1 + displayWeekdays.count
        let padding: CGFloat = 16
        let spacing: CGFloat = CGFloat(totalColumns - 1) * 1
        let availableWidth = screenWidth - padding - spacing
        
        if isTimeColumn {
            return availableWidth * 0.15
        } else {
            return (availableWidth * 0.85) / CGFloat(displayWeekdays.count)
        }
    }
    
    private func findCourse(period: Int, weekday: String) -> Course? {
        return currentCourses.first { course in
            course.period == period && course.weekday == weekday
        }
    }
}

#Preview {
    TimetableView()
        .environmentObject(AppState())
}
