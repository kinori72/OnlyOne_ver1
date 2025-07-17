import SwiftUI

enum CalendarDisplayMode: String, CaseIterable {
    case month = "月"
    case year = "年"
    
    var displayName: String {
        return self.rawValue
    }
}

struct CalendarView: View {
    @EnvironmentObject var appState: AppState
    @State private var displayMode: CalendarDisplayMode = .month
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var showingDetail = false
    @State private var detailDate = Date()
    @State private var showingAddEvent = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // カスタムナビゲーションヘッダー
                    CalendarNavigationHeader(
                        displayMode: $displayMode,
                        currentDate: $currentDate,
                        selectedDate: $selectedDate,
                        showingAddEvent: $showingAddEvent
                    )
                    
                    // 表示内容
                    switch displayMode {
                    case .month:
                        MonthCalendarView(
                            currentDate: $currentDate,
                            selectedDate: $selectedDate,
                            showingDetail: $showingDetail,
                            detailDate: $detailDate,
                            availableHeight: geometry.size.height
                        )
                        .environmentObject(appState)
                        
                    case .year:
                        YearCalendarView(
                            currentDate: $currentDate,
                            displayMode: $displayMode
                        )
                        .environmentObject(appState)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingDetail) {
                DayDetailView(date: detailDate)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(selectedDate: selectedDate ?? currentDate)
                    .environmentObject(appState)
            }
        }
    }
}

struct CalendarNavigationHeader: View {
    @Binding var displayMode: CalendarDisplayMode
    @Binding var currentDate: Date
    @Binding var selectedDate: Date?
    @Binding var showingAddEvent: Bool
    
    private let calendar = Calendar.current
    
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年"
        return formatter
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 年表示部分
            HStack {
                Button(action: {
                    if displayMode == .year {
                        // 前年へ
                        if let previousYear = calendar.date(byAdding: .year, value: -1, to: currentDate) {
                            currentDate = previousYear
                        }
                    } else {
                        // 年表示に戻る
                        displayMode = .year
                        selectedDate = nil
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text(yearFormatter.string(from: currentDate))
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // 右上は予定追加ボタンのみ
                Button(action: {
                    showingAddEvent = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                
                if displayMode == .year {
                    Button(action: {
                        // 次年へ
                        if let nextYear = calendar.date(byAdding: .year, value: 1, to: currentDate) {
                            currentDate = nextYear
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 月表示部分（月モードのときのみ）
            if displayMode == .month {
                HStack {
                    Text(monthFormatter.string(from: currentDate))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct MonthCalendarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var currentDate: Date
    @Binding var selectedDate: Date?
    @Binding var showingDetail: Bool
    @Binding var detailDate: Date
    let availableHeight: CGFloat
    
    private let calendar = Calendar.current
    
    // カレンダー部分の高さを計算（画面の半分程度）
    private var calendarHeight: CGFloat {
        availableHeight * 0.5
    }
    
    // 予定プレビュー部分の高さ
    private var previewHeight: CGFloat {
        availableHeight * 0.5 - 100 // ヘッダー分を引く
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 月移動コントロール
            HStack {
                Button(action: {
                    if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) {
                        currentDate = previousMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                        currentDate = nextMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            // カレンダーグリッド（高さを制限）
            VStack(spacing: 0) {
                // 曜日ヘッダー
                HStack(spacing: 0) {
                    ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { weekday in
                        Text(weekday)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 25)
                    }
                }
                
                Divider()
                
                // 日付グリッド（コンパクトなサイズ）
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 2) {
                    ForEach(calendarDates, id: \.self) { date in
                        CompactMonthDateCell(
                            date: date,
                            currentMonth: currentDate,
                            selectedDate: selectedDate,
                            events: dayEvents(for: date),
                            tasks: dayTasks(for: date),
                            shifts: dayShifts(for: date),
                            onTap: { date in
                                selectedDate = date
                            }
                        )
                        .frame(height: 45) // セルの高さを小さく
                    }
                }
            }
            .frame(height: calendarHeight)
            
            Divider()
            
            // 選択日の予定表示（画面の半分を使用）
            if let selectedDate = selectedDate {
                DayEventsList(
                    date: selectedDate,
                    events: dayEvents(for: selectedDate),
                    tasks: dayTasks(for: selectedDate),
                    shifts: dayShifts(for: selectedDate),
                    onEventTap: { date in
                        detailDate = date
                        showingDetail = true
                    }
                )
                .frame(height: previewHeight)
            } else {
                VStack {
                    Spacer()
                    Text("日付を選択してください")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Spacer()
                }
                .frame(height: previewHeight)
                .background(Color(.systemGray6))
            }
        }
    }
    
    private var calendarDates: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        
        var dates: [Date] = []
        
        // 前月の日付
        for i in 1..<firstWeekday {
            if let date = calendar.date(byAdding: .day, value: -(firstWeekday - i), to: firstOfMonth) {
                dates.append(date)
            }
        }
        
        // 当月の日付
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 0
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }
        
        // 次月の日付
        let totalCells = 42
        let remainingCells = totalCells - dates.count
        let lastOfMonth = calendar.date(byAdding: .day, value: daysInMonth - 1, to: firstOfMonth)!
        
        for i in 1...remainingCells {
            if let date = calendar.date(byAdding: .day, value: i, to: lastOfMonth) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func dayEvents(for date: Date) -> [Event] {
        appState.events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func dayTasks(for date: Date) -> [Task] {
        appState.tasks.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func dayShifts(for date: Date) -> [Shift] {
        appState.shifts.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

struct CompactMonthDateCell: View {
    let date: Date
    let currentMonth: Date
    let selectedDate: Date?
    let events: [Event]
    let tasks: [Task]
    let shifts: [Shift]
    let onTap: (Date) -> Void
    
    private let calendar = Calendar.current
    
    private var isCurrentMonth: Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var isSelected: Bool {
        if let selectedDate = selectedDate {
            return calendar.isDate(date, inSameDayAs: selectedDate)
        }
        return false
    }
    
    private var isHoliday: Bool {
        let components = calendar.dateComponents([.month, .day], from: date)
        if let month = components.month, let day = components.day {
            switch (month, day) {
            case (1, 1): return true // 元日
            case (2, 11): return true // 建国記念日
            case (4, 29): return true // 昭和の日
            case (5, 3): return true // 憲法記念日
            case (5, 4): return true // みどりの日
            case (5, 5): return true // こどもの日
            case (8, 11): return true // 山の日
            case (11, 3): return true // 文化の日
            case (11, 23): return true // 勤労感謝の日
            case (12, 23): return true // 天皇誕生日
            default: return false
            }
        }
        return false
    }
    
    var body: some View {
        Button(action: {
            onTap(date)
        }) {
            VStack(spacing: 1) {
                // 日付（小さく表示）
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .medium))
                    .foregroundColor(dateTextColor)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(backgroundFillColor)
                    )
                
                // イベントインジケーター（小さく）
                HStack(spacing: 1) {
                    if !events.isEmpty {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 3, height: 3)
                    }
                    if !tasks.isEmpty {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 3, height: 3)
                    }
                    if !shifts.isEmpty {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 3, height: 3)
                    }
                }
                .frame(height: 6)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Rectangle()
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                Rectangle()
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dateTextColor: Color {
        if !isCurrentMonth {
            return .secondary
        } else if isHoliday || calendar.component(.weekday, from: date) == 1 {
            return .red
        } else if isToday {
            return .white
        } else {
            return .primary
        }
    }
    
    private var backgroundFillColor: Color {
        if isToday {
            return .red
        } else {
            return .clear
        }
    }
}

struct DayEventsList: View {
    @EnvironmentObject var workplaceManager: WorkplaceManager
    let date: Date
    let events: [Event]
    let tasks: [Task]
    let shifts: [Shift]
    let onEventTap: (Date) -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 日付ヘッダー（コンパクト）
            HStack {
                Text(DateFormatter.dayFormatter.string(from: date))
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            if events.isEmpty && tasks.isEmpty && shifts.isEmpty {
                VStack {
                    Spacer()
                    Text("予定はありません")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        // イベント
                        ForEach(events.sorted { $0.startTime < $1.startTime }) { event in
                            EventPreviewRow(event: event, onTap: onEventTap)
                        }
                        
                        // タスク
                        ForEach(tasks) { task in
                            TaskPreviewRow(task: task, onTap: onEventTap)
                        }
                        
                        // シフト
                        ForEach(shifts) { shift in
                            ShiftPreviewRow(shift: shift, onTap: onEventTap)
                                .environmentObject(workplaceManager)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

struct EventPreviewRow: View {
    let event: Event
    let onTap: (Date) -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        Button(action: {
            onTap(event.date)
        }) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !event.isAllDay {
                        Text(timeFormatter.string(from: event.startTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("終日")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TaskPreviewRow: View {
    let task: Task
    let onTap: (Date) -> Void
    
    var body: some View {
        Button(action: {
            onTap(task.date)
        }) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("タスク")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color.orange.opacity(0.05))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShiftPreviewRow: View {
    @EnvironmentObject var workplaceManager: WorkplaceManager
    let shift: Shift
    let onTap: (Date) -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        Button(action: {
            onTap(shift.date)
        }) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(workplaceManager.getWorkplace(by: shift.workplaceId)?.color.color ?? Color.gray)
                    .frame(width: 3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(workplaceManager.getWorkplace(by: shift.workplaceId)?.name ?? "シフト")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(timeFormatter.string(from: shift.startTime)) - \(timeFormatter.string(from: shift.endTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color.green.opacity(0.05))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        return formatter
    }()
}

#Preview {
    CalendarView()
        .environmentObject(AppState())
        .environmentObject(WorkplaceManager())
}
