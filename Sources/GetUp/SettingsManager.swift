import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    // Keys
    private let kInitialInterval = "initialInterval"
    private let kSnoozeInterval = "snoozeInterval"
    
    // Default values (in minutes)
    private let defaultInitial: Double = 30
    private let defaultSnooze: Double = 15
    
    var initialIntervalMinutes: Double {
        get { defaults.double(forKey: kInitialInterval) == 0 ? defaultInitial : defaults.double(forKey: kInitialInterval) }
        set { defaults.set(newValue, forKey: kInitialInterval) }
    }
    
    var snoozeIntervalMinutes: Double {
        get { defaults.double(forKey: kSnoozeInterval) == 0 ? defaultSnooze : defaults.double(forKey: kSnoozeInterval) }
        set { defaults.set(newValue, forKey: kSnoozeInterval) }
    }
    
    // Helpers for seconds (used by the timer)
    var initialIntervalSeconds: TimeInterval { initialIntervalMinutes * 60 }
    var snoozeIntervalSeconds: TimeInterval { snoozeIntervalMinutes * 60 }
    
    // Start at Login Logic
    var startAtLogin: Bool {
        get {
            let url = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/LaunchAgents/com.getup.reminder.app.plist")
            return FileManager.default.fileExists(atPath: url.path)
        }
        set {
            if newValue {
                createLaunchAgent()
            } else {
                removeLaunchAgent()
            }
            objectWillChange.send()
        }
    }
    
    private func createLaunchAgent() {
        guard let appPath = Bundle.main.executablePath else { return }
        
        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.getup.reminder.app</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(appPath)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>ProcessType</key>
            <string>Interactive</string>
        </dict>
        </plist>
        """
        
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.getup.reminder.app.plist")
        
        do {
            // Ensure directory exists
            let directory = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try plistContent.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Error creating LaunchAgent: \(error)")
        }
    }
    
    private func removeLaunchAgent() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/com.getup.reminder.app.plist")
        
        try? FileManager.default.removeItem(at: url)
    }
}
