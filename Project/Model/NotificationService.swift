
import Foundation
class NotificationService {
    
    static let didLaunchFromNotification = NSNotification.Name("didLaunchFromNotification")
    static var launchedFromNotification = false
    
    static func newNotificationRecieved() {
        launchedFromNotification = true
        NotificationCenter.default.post(name: didLaunchFromNotification, object: nil)
    }
}
