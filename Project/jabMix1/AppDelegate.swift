
import UIKit
import Firebase
import FirebaseAuth
import UserNotifications
import GooglePlaces
import TwitterKit
import RealmSwift


var currentUser:Users?
let realm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    
    var window: UIWindow?
    override init(){
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        //MARK: Twitter Login setup
        TWTRTwitter.sharedInstance().start(withConsumerKey:"Yhz8vaONM0tuGJzMK63pV1De2", consumerSecret:"Jml86g4iHigvhOPBjvMgfc7JUB0HNj4MMfYFG9klowkpVFz72x")

        
//        let BarButtonItemAppearance = UIBarButtonItem.appearance()
//        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        
        // Override point for customization after application launch
        // AIzaSyCj7S5IlfC1bZkgJLBvUgky_yxnd3MZtSU
       IQKeyboardManager.sharedManager().enable = true
      
        IQKeyboardManager.sharedManager().overrideKeyboardAppearance = true
        IQKeyboardManager.sharedManager().keyboardAppearance = .dark
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 70.0
        
        GMSPlacesClient.provideAPIKey("AIzaSyCj7S5IlfC1bZkgJLBvUgky_yxnd3MZtSU")
      
        FirebaseApp.configure()
        
        // Enable Firebase Cloud Messaging
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        registerForNotifications()
        
        if Auth.auth().currentUser?.uid != nil {
            
            //user is logged in
            
            logUser()
            
        }else{
            
            //user is not logged in
            let loginCoordinator: LoginCoordinator = {
                return LoginCoordinator(window: self.window!)
            }()
            
            loginCoordinator.start()
            
        }
        
        
        // Listen for changes in the users authenication state
//        Auth.auth().addStateDidChangeListener { auth, user in
//            DispatchQueue.main.async {
//                
//                // If no user is authenticated, go to the login screen
//                if user == nil {
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let login = storyboard.instantiateViewController(withIdentifier: "Login")
//                    self.window?.rootViewController = login
//                    self.window?.makeKeyAndVisible()
//                }
//            }
//        }

        
        return true
    }

    func logUser(){
        
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                 self.window?.rootViewController = instantiatePreferencesViewController()
            }
        }
        
    }
    
    /**
     Request to register push notifications
     
     */
    func registerForNotifications() {
        
            if #available(iOS 10.0, *) {
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]){
                    (granted,error) in
                    DispatchQueue.main.async {
                        if granted{
                            UIApplication.shared.registerForRemoteNotifications()
                        } else {
                            print("User Notification permission denied: \(String(describing: error?.localizedDescription))")
                        }
                    }
                    
                }
            } else {
                // Fallback on earlier versions
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            }
        
    }
    

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification here for iOS 10.0 and up
        NotificationService.newNotificationRecieved()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        print("willPresent")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        guard let user = Auth.auth().currentUser else { return }
        let db = Database.database().reference()
        let ref = db.child("FCMToken/\(user.uid)")
        ref.setValue(fcmToken)
    }
    
    //Messaging.messaging().shouldEstablishDirectChannel to true.
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

