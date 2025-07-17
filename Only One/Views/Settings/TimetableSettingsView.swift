// NEW FILE
import SwiftUI

struct TimetableSettingsView: View {
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
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("表示設定")) {
                    Toggle("土曜日を表示", isOn: $showSaturday)
                }
                
                Section(header: Text("時限設定")) {
                    PeriodTimeRow(
                        period: "1限",
                        startTime: $period1Start,
                        endTime: $period1End
                    )
                    
                    PeriodTimeRow(
                        period: "2限",
                        startTime: $period2Start,
                        endTime: $period2End
                    )
                    
                    PeriodTimeRow(
                        period: "3限",
                        startTime: $period3Start,
                        endTime: $period3End
                    )
                    
                    PeriodTimeRow(
                        period: "4限",
                        startTime: $period4Start,
                        endTime: $period4End
                    )
                    
                    PeriodTimeRow(
                        period: "5限",
                        startTime: $period5Start,
                        endTime: $period5End
                    )
                    
                    PeriodTimeRow(
                        period: "6限",
                        startTime: $period6Start,
                        endTime: $period6End
                    )
                }
                
                Section(footer: Text("時限の時刻を変更すると、時間割表示に即座に反映されます。")) {
                    EmptyView()
                }
            }
            .navigationTitle("時間割設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PeriodTimeRow: View {
    let period: String
    @Binding var startTime: String
    @Binding var endTime: String
    
    @State private var showingStartTimePicker = false
    @State private var showingEndTimePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(period)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Button(action: {
                    showingStartTimePicker = true
                }) {
                    HStack {
                        Text("開始")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(startTime)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("〜")
                    .foregroundColor(.secondary)
                
                Button(action: {
                    showingEndTimePicker = true
                }) {
                    HStack {
                        Text("終了")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(endTime)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showingStartTimePicker) {
            TimetableTimePickerView(
                title: "\(period) 開始時刻",
                selectedTime: $startTime
            )
        }
        .sheet(isPresented: $showingEndTimePicker) {
            TimetableTimePickerView(
                title: "\(period) 終了時刻",
                selectedTime: $endTime
            )
        }
    }
}

struct TimetableTimePickerView: View {
    let title: String
    @Binding var selectedTime: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "時刻を選択",
                    selection: $selectedDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        selectedTime = timeFormatter.string(from: selectedDate)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let date = timeFormatter.date(from: selectedTime) {
                selectedDate = date
            }
        }
    }
}

#Preview {
    TimetableSettingsView()
}
