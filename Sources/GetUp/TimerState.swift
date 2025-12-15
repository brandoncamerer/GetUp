import Foundation
import Combine

class TimerState: ObservableObject {
    static let shared = TimerState()
    
    @Published var nextNotificationDate: Date?
    @Published var totalInterval: TimeInterval = 30 * 60 // Default
    
    func updateTarget(date: Date, interval: TimeInterval) {
        DispatchQueue.main.async {
            self.nextNotificationDate = date
            self.totalInterval = interval
        }
    }
}
