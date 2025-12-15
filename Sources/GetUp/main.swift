import Cocoa

// Check for existing instances
let bundleIdentifier = "com.getup.reminder.app"
let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
let currentPid = ProcessInfo.processInfo.processIdentifier

for app in runningApps {
    if app.processIdentifier != currentPid {
        print("Another instance of GetUp is already running (PID: \(app.processIdentifier)). Terminating this instance.")
        exit(0)
    }
}

// Create the application instance
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Run the app
app.run()
