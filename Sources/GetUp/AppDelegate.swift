import Cocoa
import UserNotifications
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var settingsWindow: NSWindow?
    var alertWindow: NSWindow?
    var menuBarTimer: Timer?
    var isAlertVisible = false
    let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup Menu Bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "figure.walk", accessibilityDescription: "GetUp")
            button.action = #selector(togglePopover)
            // Use monospaced font to prevent jitter
            button.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        }
        
        setupPopover()
        setupNotifications()
        
        // Start the initial timer if not already running
        checkAndStart()
        
        // Start updating menu bar title
        startMenuBarTimer()
        
        // Observe system wake to handle timer state
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(didWake), name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    @objc func didWake(_ notification: Notification) {
        print("System woke up. Checking timer state...")
        if let target = TimerState.shared.nextNotificationDate {
            let remaining = target.timeIntervalSinceNow
            // If timer has expired (negative remaining), we want to show the alert immediately
            // instead of silently restarting. The updateMenuBarTitle() function handles the
            // logic for expired timers (shows "GET UP!" and triggers alert).
            print("Timer check on wake. Remaining: \(remaining)")
            updateMenuBarTitle()
        }
    }
    
    func startMenuBarTimer() {
        // Update immediately to set initial width
        updateMenuBarTitle()
        menuBarTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMenuBarTitle()
        }
    }
    
    func updateMenuBarTitle() {
        guard let button = statusItem.button,
              let target = TimerState.shared.nextNotificationDate else {
            statusItem.button?.title = ""
            return
        }
        
        let remaining = target.timeIntervalSinceNow
        if remaining > 0 {
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            button.title = String(format: " %02d:%02d", minutes, seconds)
        } else {
            button.title = " GET UP!"
            // Trigger Alert Window if not already shown
            if !isAlertVisible {
                showAlert(isSnooze: false) // Default to regular alert
            }
        }
    }
    
    func showAlert(isSnooze: Bool) {
        isAlertVisible = true
        
        // Play Sound
        NSSound(named: "Glass")?.play()
        
        // Create Window
        if alertWindow == nil {
            let alertView = AlertView(
                onSnooze: { [weak self] in
                    self?.closeAlert()
                    print("Snoozing...")
                    self?.scheduleNotification(interval: SettingsManager.shared.snoozeIntervalSeconds, isSnooze: true)
                },
                onOK: { [weak self] in
                    self?.closeAlert()
                    print("Acknowledged. Resetting timer.")
                    self?.scheduleNotification(interval: SettingsManager.shared.initialIntervalSeconds, isSnooze: false)
                },
                isSnoozeAvailable: !isSnooze // If it IS a snooze alert, no snooze button (per original request)
            )
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 200),
                styleMask: [.borderless, .nonactivatingPanel], // Borderless for custom look
                backing: .buffered,
                defer: false
            )
            window.contentViewController = NSHostingController(rootView: alertView)
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = true
            window.level = .floating // Float above other windows
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary] // Show on all spaces
            
            self.alertWindow = window
        }
        
        // Position relative to status item button
        if let button = statusItem.button, let buttonWindow = button.window {
            let buttonFrame = buttonWindow.frame
            let windowSize = alertWindow!.frame.size
            
            // Center horizontally relative to button
            var x = buttonFrame.midX - (windowSize.width / 2)
            
            // Position below the button with a small gap
            let y = buttonFrame.minY - windowSize.height - 5
            
            // Ensure it stays on screen (horizontally)
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                if x + windowSize.width > screenFrame.maxX {
                    x = screenFrame.maxX - windowSize.width - 10
                }
                if x < screenFrame.minX {
                    x = screenFrame.minX + 10
                }
            }
            
            alertWindow?.setFrameOrigin(NSPoint(x: x, y: y))
        } else if let screen = NSScreen.main {
            // Fallback to Top Right
            let screenRect = screen.visibleFrame
            let windowRect = alertWindow!.frame
            let x = screenRect.maxX - windowRect.width - 20 // 20px margin
            let y = screenRect.maxY - windowRect.height - 20 // 20px margin
            alertWindow?.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        print("Showing alert window at \(alertWindow?.frame ?? .zero)")
        alertWindow?.makeKeyAndOrderFront(nil)
        alertWindow?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func closeAlert() {
        alertWindow?.close()
        alertWindow = nil
        isAlertVisible = false
    }
    
    func setupPopover() {
        let statusView = StatusView(
            onOpenSettings: { [weak self] in
                self?.closePopover(sender: nil)
                self?.openSettings()
            },
            onQuit: { [weak self] in
                self?.quitApp()
            },
            onReset: { [weak self] in
                self?.restartTimer()
                self?.closePopover(sender: nil)
            }
        )
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 240, height: 220)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: statusView)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                // Standard positioning: .minY (below the button)
                // No manual offsets, let NSPopover handle the arrow and positioning
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                
                // Force update timer when opening
                TimerState.shared.objectWillChange.send()
                
                // Bring to front
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    @objc func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView {
                // On Save
                self.settingsWindow?.close()
                self.restartTimer()
            }
            
            let hostingController = NSHostingController(rootView: settingsView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "GetUp Settings"
            window.styleMask = [.titled, .closable]
            window.center()
            window.isReleasedWhenClosed = false
            self.settingsWindow = window
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    func setupNotifications() {
        center.delegate = self
        
        // Define Actions
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "Snooze", options: [])
        let okAction = UNNotificationAction(identifier: "OK_ACTION", title: "OK", options: [])
        
        // Define Categories
        let regularCategory = UNNotificationCategory(identifier: "REGULAR", actions: [snoozeAction, okAction], intentIdentifiers: [], options: .customDismissAction)
        let snoozeCategory = UNNotificationCategory(identifier: "SNOOZE", actions: [okAction], intentIdentifiers: [], options: .customDismissAction)
        
        center.setNotificationCategories([regularCategory, snoozeCategory])
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Permissions granted.")
            } else {
                print("Permissions denied.")
            }
        }
    }
    
    func checkAndStart() {
        // Always start fresh to ensure sync and clear old notifications
        print("Starting timer.")
        self.restartTimer()
    }
    
    func restartTimer() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        print("Timer restarted with new settings.")
        scheduleNotification(interval: SettingsManager.shared.initialIntervalSeconds, isSnooze: false)
    }
    
    func scheduleNotification(interval: TimeInterval, isSnooze: Bool) {
        // Update State
        let targetDate = Date().addingTimeInterval(interval)
        TimerState.shared.updateTarget(date: targetDate, interval: interval)
        
        print("Timer started for \(interval) seconds.")
        
        // Note: We no longer schedule system notifications (UNNotificationRequest)
        // because we are using the custom persistent AlertWindow.
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        print("Action received: \(actionIdentifier)")
        
        switch actionIdentifier {
        case "SNOOZE_ACTION":
            print("Snoozing...")
            scheduleNotification(interval: SettingsManager.shared.snoozeIntervalSeconds, isSnooze: true)
            
        case "OK_ACTION", UNNotificationDefaultActionIdentifier, UNNotificationDismissActionIdentifier:
            print("Acknowledged. Resetting timer.")
            scheduleNotification(interval: SettingsManager.shared.initialIntervalSeconds, isSnooze: false)
            
        default:
            // Handle any other case as a reset (fallback)
            print("Unknown action. Resetting timer.")
            scheduleNotification(interval: SettingsManager.shared.initialIntervalSeconds, isSnooze: false)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
