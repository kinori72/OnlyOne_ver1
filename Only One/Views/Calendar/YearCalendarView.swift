import SwiftUI

struct YearCalendarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var currentDate: Date
    @Binding var displayMode: CalendarDisplayMode
    @State private var currentYear: Int
    
    private let calendar = Calendar.current
    
    init(currentDate: Binding<Date>, displayMode: Binding<CalendarDisplayMode>) {
        self._currentDate = currentDate
        self._displayMode = displayMode
        let year = Calendar.current.component(.year, from: currentDate.wrappedValue)
        self._currentYear = State(initialValue: year)
    }
    
    // 現在年を中心に前後10年を表示
    private var years: [Int] {
        Array((currentYear - 10)...(currentYear + 10))
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 32) {
                    ForEach(years, id: \.self) { year in
                        YearSectionView(
                            year: year,
                            events: appState.events,
                            tasks: appState.tasks,
                            shifts: appState.shifts,
                            onMonthTap: { selectedMonth in
                                currentDate = selectedMonth
                                displayMode = .month
                            }
                        )
                        .id(year)
                        .onAppear {
                            // 表示年を更新
                            if year == currentYear {
                                let newDate = calendar.date(from: DateComponents(year: year, month: calendar.component(.month, from: currentDate), day: 1)) ?? currentDate
                                currentDate = newDate
                            }
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                // 現在年にスクロール
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo(currentYear, anchor: .center)
                }
            }
            .onChange(of: currentDate) { newDate in
                let newYear = calendar.component(.year, from: newDate)
                if newYear != currentYear {
                    currentYear = newYear
                    proxy.scrollTo(newYear, anchor: .center)
                }
            }
        }
    }
}

struct YearSectionView: View {
    let year: Int
    let events: [Event]
    let tasks: [Task]
    let shifts: [Shift]
    let onMonthTap: (Date) -> Void
    
    private let calendar = Calendar.current
    
    // 12ヶ月分の月を生成
    private var months: [Date] {
        (1...12).compactMap { month in
            calendar.date(from: DateComponents(year: year, month: month, day: 1))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(year)")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 横3列×縦4行のレイアウト
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                ForEach(months, id: \.self) { month in
                    YearMonthView(
                        month: month,
                        events: events,
                        tasks: tasks,
                        shifts: shifts,
                        onMonthTap: onMonthTap
                    )
                }
            }
        }
    }
}

struct YearMonthView: View {
    let month: Date
    let events: [Event]
    let tasks: [Task]
    let shifts: [Shift]
    let onMonthTap: (Date) -> Void
    
    private let calendar = Calendar.current
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter
    }()
    
    // イベントの存在チェックを最適化
    private var datesWithContent: Set<Int> {
        var dates = Set<Int>()
        
        for event in events {
            if calendar.isDate(event.date, equalTo: month, toGranularity: .month) {
                dates.insert(calendar.component(.day, from: event.date))
            }
        }
        
        for task in tasks {
            if calendar.isDate(task.date, equalTo: month, toGranularity: .month) {
                dates.insert(calendar.component(.day, from: task.date))
            }
        }
        
        for shift in shifts {
            if calendar.isDate(shift.date, equalTo: month, toGranularity: .month) {
                dates.insert(calendar.component(.day, from: shift.date))
            }
        }
        
        return dates
    }
    
    var body: some View {
        Button(action: {
            onMonthTap(month)
        }) {
            VStack(spacing: 6) {
                // 月のヘッダー
                Text(monthFormatter.string(from: month))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.vertical, 4)
                
                // シンプルな日付グリッド
                VStack(spacing: 2) {
                    // 曜日ヘッダー
                    HStack(spacing: 2) {
                        ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                            Text(day)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 10)
                        }
                    }
                    
                    // 日付セル（週ごとに表示）
                    ForEach(weeksInMonth, id: \.self) { week in
                        HStack(spacing: 2) {
                            ForEach(week, id: \.self) { date in
                                YearDateCell(
                                    date: date,
                                    month: month,
                                    hasContent: datesWithContent.contains(calendar.component(.day, from: date))
                                )
                            }
                        }
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var weeksInMonth: [[Date]] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        
        var allDates: [Date] = []
        
        // 前月の日付を追加
        for i in 1..<firstWeekday {
            if let date = calendar.date(byAdding: .day, value: -(firstWeekday - i), to: firstOfMonth) {
                allDates.append(date)
            }
        }
        
        // 当月の日付を追加
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                allDates.append(date)
            }
        }
        
        // 次月の日付を追加（6週間分になるまで）
        let totalCells = 42
        let remainingCells = totalCells - allDates.count
        let lastOfMonth = calendar.date(byAdding: .day, value: daysInMonth - 1, to: firstOfMonth)!
        
        for i in 1...remainingCells {
            if let date = calendar.date(byAdding: .day, value: i, to: lastOfMonth) {
                allDates.append(date)
            }
        }
        
        // 週ごとに分割
        return allDates.chunked(into: 7)
    }
}

struct YearDateCell: View {
    let date: Date
    let month: Date
    let hasContent: Bool
    
    private let calendar = Calendar.current
    
    private var isCurrentMonth: Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var isHoliday: Bool {
        let components = calendar.dateComponents([.month, .day], from: date)
        if let month = components.month, let day = components.day {
            switch (month, day) {
            case (1, 1): return true
            case (2, 11): return true
            case (4, 29): return true
            case (5, 3): return true
            case (5, 4): return true
            case (5, 5): return true
            case (8, 11): return true
            case (11, 3): return true
            case (11, 23): return true
            case (12, 23): return true
            default: return false
            }
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 8, weight: isToday ? .bold : .regular))
                               .foregroundColor(dateTextColor)
                           
                           // 下線でイベントを表示
                           Rectangle()
                               .fill(hasContent && isCurrentMonth ? Color.accentColor : Color.clear)
                               .frame(height: hasContent ? 1 : 0)
                       }
                       .frame(maxWidth: .infinity)
                       .frame(height: 14)
                       .background(
                           Circle()
                               .fill(isToday ? Color.red : Color.clear)
                               .scaleEffect(0.8)
                       )
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
                }

                // 配列を指定されたサイズに分割するヘルパー
                extension Array {
                   func chunked(into size: Int) -> [[Element]] {
                       return stride(from: 0, to: count, by: size).map {
                           Array(self[$0..<Swift.min($0 + size, count)])
                       }
                   }
                }

                #Preview {
                   YearCalendarView(currentDate: .constant(Date()), displayMode: .constant(.year))
                       .environmentObject(AppState())
                }
