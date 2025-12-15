import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    var onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("GetUp Settings")
                .font(.headline)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Reminder Interval (minutes)")
                TextField("Minutes", value: $settings.initialIntervalMinutes, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading) {
                Text("Snooze Interval (minutes)")
                TextField("Minutes", value: $settings.snoozeIntervalMinutes, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Toggle("Start at Login", isOn: $settings.startAtLogin)
            
            Divider()
            
            HStack {
                Spacer()
                Button("Save & Restart Timer") {
                    onSave()
                }
            }
        }
        .padding()
        .frame(width: 300)
    }
}
