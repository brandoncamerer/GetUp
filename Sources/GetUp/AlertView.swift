import SwiftUI

struct AlertView: View {
    var onSnooze: () -> Void
    var onOK: () -> Void
    var isSnoozeAvailable: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.walk")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("GET UP!")
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(.primary)
            
            Text("Time to stand up and stretch.")
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                if isSnoozeAvailable {
                    Button(action: onSnooze) {
                        Text("Snooze (15m)")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: onOK) {
                    Text("OK")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 10)
        }
        .padding(30)
        .frame(width: 350)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(16)
    }
}
