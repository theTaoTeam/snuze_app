import UIKit
import Flutter
import Foundation
import MediaPlayer
import UserNotifications
import Stripe
import Firebase

@available(iOS 10.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var appLaunchTime = Date()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
    let alarmChannel = FlutterMethodChannel.init(name: "snuze.app/alarm",
                                                   binaryMessenger: controller);
    STPPaymentConfiguration.shared().publishableKey = "pk_test_YhN3AX1KBNqQQbDtGjctrCZd"
    alarmChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: FlutterResult) -> Void in
      if ("setAlarm" == call.method) {
        self.setAlarm(result: result, args: call.arguments as! String)
      } else if ("cancelAlarm" == call.method) {
        self.cancelAlarm(result: result, args: call.arguments as! String)
      }
    });
    
    let stripeChannel = FlutterMethodChannel.init(name: "snuze.app/stripe", binaryMessenger: controller);
    stripeChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if ("createStripeToken" == call.method) {
            self.createStripeToken(result: result, args: call.arguments as! String)
        }
    })
    
    
    
    GeneratedPluginRegistrant.register(with: self)
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        
        // Set launch date for time-related functionality
        appLaunchTime = Date()
        
        // Initialize Flutter
        setupFlutter()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions);
    }
    
    private func setupFlutter() {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
        let alarmChannel = FlutterMethodChannel.init(name: "snuze.app/alarm",
                                                     binaryMessenger: controller);
        alarmChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if ("setAlarm" == call.method) {
                self.setAlarm(result: result, args: call.arguments as! String)
            } else if ("cancelAlarm" == call.method) {
                self.cancelAlarm(result: result, args: call.arguments as! String)
            }
        });
        
        GeneratedPluginRegistrant.register(with: self)
    }
    
    private func createStripeToken(result: @escaping FlutterResult, args: String) {
        let json: NSDictionary = args.parseJSONString!;
        let cardParams = STPCardParams()
        cardParams.number = json["number"] as? String;
        cardParams.expMonth = (json["expMonth"] as? UInt)!;
        cardParams.expYear = (json["expYear"] as? UInt)!;
        cardParams.cvc = json["cvc"] as? String;
        
        STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
            guard let token = token, error == nil else {
                result("ERROR_STRIPE")
                return
            }
            let _: [String:Any] = [
                "tokenId": token.tokenId
            ]
            
            result(token.tokenId)
            return
        }
    }
    
    private func cancelAlarm(result: FlutterResult, args: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        print("CANCELLED ALARM")
    }
    
    private func setupNotificationOptions() {
        //        Tried to work through error and couldn't figure it out, will work on this later
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Snüze",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Stop",
                                                 options: UNNotificationActionOptions(rawValue: 0))
        
        // Define the notification type
        let snuzeAlarmCategory =
            UNNotificationCategory(identifier: "SNUZE_ALARM", actions: [acceptAction, declineAction], intentIdentifiers: ["SNUZE"])
        
        
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([snuzeAlarmCategory])
        
        var authorizationOptions:UNAuthorizationOptions = []
        if #available(iOS 12.0, *) {
            authorizationOptions = [.alert, .sound, .criticalAlert]
        } else {
            // Fallback on earlier versions
            authorizationOptions = [.alert, .sound] // Critical alert only available in iOS 12+
        }
        
        notificationCenter.requestAuthorization(options: authorizationOptions)
        { (granted, error) in
            // Enable or disable features based on authorization.
            notificationCenter.delegate = self
        }
        
        
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            print(settings.authorizationStatus == .authorized)
            guard settings.authorizationStatus == .authorized else {return}
        }
        
    }
    
    private func setAlarm(result: FlutterResult, args: String) {
        // Don't set any alarms within 5 seconds of app launching
        guard Date().timeIntervalSince(appLaunchTime) > 5 else {
            print("Not setting alarm because within 5 seconds of app launching.")
            
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print(settings.debugDescription)
            }
            return
        }
        
        let json: NSDictionary = args.parseJSONString!;
        
        guard let hour = json["hour"] as? Int, let minute = json["minute"] as? Int else {
            print("Invalid hour/minute args passed in from Flutter.")
            return
        }
        
        setAlarmWithMultipleNotifications(hour: hour, minute: minute)
        
        return;
    }
    
    private func setAlarmWithMultipleNotifications(hour: Int, minute: Int) {
        let lengthOfNotificationOnscreen = 7
        let maxSeconds = 60 * 5 // Five minutes
        let numIntervals = Int(maxSeconds / lengthOfNotificationOnscreen)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        // Remove all pending notifications
        notificationCenter.removeAllPendingNotificationRequests()
        
        var alarmTime = DateComponents()
        alarmTime.calendar = Calendar.current
        alarmTime.hour = hour
        alarmTime.minute = minute
        alarmTime.second = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        
        // Schedule notifications at specifed interval up to max time
        for i in 0 ..< numIntervals {
            alarmTime.second = i * lengthOfNotificationOnscreen
            let request = createAlarmRequest(dateComponents: alarmTime)
            
            if let date = Calendar.current.date(from: alarmTime) {
                let dateString = dateFormatter.string(from: date)
                print("Adding notification request at \(dateString)")
            }
            else {
                print("Adding notification request at unknown time.")
            }
            
            // Schedule the notification request
            notificationCenter.add(request) { (error) in
                if error != nil {
                    // Handle any errors.
                    print(error!)
                    print("THERE WAS AN ERROR ADDING THE NOTIFICATION REQUEST")
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let requests = notificationCenter.getPendingNotificationRequests(completionHandler: { (requests) in
                print("There are \(requests.count) pending notification requests.")
            })
        }
    }
    
    private func createAlarmRequest(dateComponents: DateComponents) -> UNNotificationRequest {
        let alarmContent = UNMutableNotificationContent()
        alarmContent.title = "Snuze Alarm"
        alarmContent.body = "Get your ass out of bed"
        //alarmContent.sound = UNNotificationSound.default()
        alarmContent.categoryIdentifier = "SNUZE_ALARM"
        if #available(iOS 12.0, *) {
            alarmContent.sound = UNNotificationSound.criticalSoundNamed("song.caf")
        } else {
            // Fallback on earlier versions
            alarmContent.sound = UNNotificationSound.init(named: "song.caf")
        }
        
        //        Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )
        //        print(trigger)
        
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: alarmContent, trigger: trigger)
        
        return request
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //        let title = notification.request.content.title
        //        let body = notification.request.content.body
        //
        //        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        //        alertController.addAction(UIAlertAction(title: "Nooooooo 😩", style: .default, handler: nil))
        
        //                self.present(alertController, animated: true, completion: nil)
        //        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        
        print("Notification triggered while app was in foreground.")
        
        center.getPendingNotificationRequests(completionHandler: { (requests) in
            print("There are \(requests.count) pending notification requests.")
        })
        
        return completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.debugDescription)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        
        let categoryID = response.actionIdentifier
        if categoryID == "Snüze" {
            // Reschedule all notifications 9 minutes from now
            
            // Send snooze action to Flutter
            
        }
        else if categoryID == "Stop" {
            print("Stopping the snüze")
        }
    }
}

extension String {
    
    var parseJSONString: NSDictionary? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            return try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        }
    }
}
