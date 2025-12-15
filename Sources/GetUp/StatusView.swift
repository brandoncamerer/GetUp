import SwiftUI

struct StatusView: View {
    @ObservedObject var timerState = TimerState.shared
    @State private var timeRemaining: TimeInterval = 0
    @State private var progress: Double = 0
    
    // Actions passed from AppDelegate
    var onOpenSettings: () -> Void
    var onQuit: () -> Void
    var onReset: () -> Void
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 12) {
            Text(timeRemaining > 0 ? "Next Stretch In" : "Time to Get Up!")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(timeRemaining > 0 ? .secondary : .red)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.2)
                    .foregroundColor(Color(NSColor.labelColor))
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(timeRemaining > 0 ? Color(NSColor.controlAccentColor) : .red)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                if timeRemaining > 0 {
                    Text(formatTime(timeRemaining))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                } else {
                    Button(action: onReset) {
                        Text("Reset")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 100, height: 100)
            .padding(.vertical, 4)
            
            Divider()
            
            HStack(spacing: 12) {
                Button(action: onOpenSettings) {
                    Label("Settings", systemImage: "gear")
                        .frame(maxWidth: .infinity)
                }
                
                Button(action: onQuit) {
                    Label("Quit", systemImage: "power")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .frame(width: 240, height: 220)
        .onReceive(timer) { _ in
            updateTimer()
        }
        .onAppear {
            updateTimer()
        }
    }
    
    func updateTimer() {
        guard let target = timerState.nextNotificationDate else {
            timeRemaining = 0
            progress = 0
            return
        }
        
        let now = Date()
        let remaining = target.timeIntervalSince(now)
        
        if remaining > 0 {
            timeRemaining = remaining
            let total = timerState.totalInterval
            progress = (total - remaining) / total
        } else {
            timeRemaining = 0
            progress = 1.0
        }
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
