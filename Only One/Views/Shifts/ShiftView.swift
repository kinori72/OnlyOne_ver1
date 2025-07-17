import SwiftUI

struct ShiftView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var workplaceManager: WorkplaceManager
    @State private var showingAddShift = false
    @State private var selectedDate = Date()
    @State private var showingWorkplaceSettings = false
    @State private var currentDate = Date()
    
    private let calendar = Calendar.current
    
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()
    
    // 現在の年月のシフトを取得
    private var currentMonthShifts: [Shift] {
        appState.shifts.filter { shift in
            calendar.isDate(shift.date, equalTo: currentDate, toGranularity: .month)
        }.sorted { $0.date < $1.date }
    }
    
    // 現在月の合計労働時間と収入を計算
    private var monthlyStats: (hours: Double, income: Double) {
        let totalHours = currentMonthShifts.reduce(0) { $0 + $1.workingHours }
        let totalIncome = currentMonthShifts.reduce(0) { sum, shift in
            if let workplace = workplaceManager.getWorkplace(by: shift.workplaceId) {
                return sum + shift.calculateWage(hourlyRate: workplace.hourlyRate)
            }
            return sum
        }
        return (totalHours, totalIncome)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 年月移動コントロール
                VStack(spacing: 12) {
                    HStack {
                        Button(action: {
                            if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) {
                                currentDate = previousMonth
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        Text(monthYearFormatter.string(from: currentDate))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                                currentDate = nextMonth
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 今日に戻るボタン
                    Button(action: {
                        currentDate = Date()
                    }) {
                        Text("今月")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.top)
                
                // 月間統計
                VStack(spacing: 12) {
                    Text("月間統計")
                        .font(.headline)
                    
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(String(format: "%.1f", monthlyStats.hours))時間")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("労働時間")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("¥\(Int(monthlyStats.income))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("給与")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !currentMonthShifts.isEmpty {
                            VStack {
                                Text("\(currentMonthShifts.count)日")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Text("勤務日数")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // シフト一覧
                if currentMonthShifts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("この月にシフトはありません")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("下のボタンからシフトを追加してください")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(currentMonthShifts) { shift in
                            ShiftListRowView(shift: shift)
                        }
                        .onDelete(perform: deleteShift)
                    }
                }
            }
            .navigationTitle("シフト")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingWorkplaceSettings = true
                    }) {
                        Image(systemName: "building.2")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedDate = currentDate
                        showingAddShift = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddShift) {
            AddShiftView(selectedDate: selectedDate)
                .environmentObject(appState)
                .environmentObject(workplaceManager)
        }
        .sheet(isPresented: $showingWorkplaceSettings) {
            WorkplaceSettingsView()
                .environmentObject(workplaceManager)
        }
    }
    
    private func deleteShift(at offsets: IndexSet) {
        for index in offsets {
            let shift = currentMonthShifts[index]
            appState.deleteShift(shift)
        }
    }
}

struct ShiftListRowView: View {
    @EnvironmentObject var workplaceManager: WorkplaceManager
    let shift: Shift
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(workplaceManager.getWorkplace(by: shift.workplaceId)?.color.color ?? Color.gray)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(dateFormatter.string(from: shift.date))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(workplaceManager.getWorkplace(by: shift.workplaceId)?.name ?? "不明な勤務先")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(timeFormatter.string(from: shift.startTime)) - \(timeFormatter.string(from: shift.endTime))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(String(format: "%.1f", shift.workingHours))時間")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                if let workplace = workplaceManager.getWorkplace(by: shift.workplaceId) {
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "yensign.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("時給: ¥\(Int(workplace.hourlyRate))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("¥\(Int(shift.calculateWage(hourlyRate: workplace.hourlyRate)))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                if shift.breakMinutes > 0 {
                    HStack {
                        Image(systemName: "pause.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("休憩: \(shift.breakMinutes)分")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                if !shift.notes.isEmpty {
                    Text(shift.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ShiftView()
        .environmentObject(AppState())
        .environmentObject(WorkplaceManager())
}
