import UIKit
import Flutter
import Foundation
import MediaPlayer
import UserNotifications
import Stripe


@available(iOS 10.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
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
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions);
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
            let tokenDict: [String:Any] = [
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
    
    private func setAlarm(result: FlutterResult, args: String) {
        let json: NSDictionary = args.parseJSONString!;
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
//        Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([snuzeAlarmCategory])
        notificationCenter.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            // Enable or disable features based on authorization.
            notificationCenter.delegate = self
        }
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            print(settings.authorizationStatus == .authorized)
            guard settings.authorizationStatus == .authorized else {return}
        }
        
        let alarmContent = UNMutableNotificationContent()
        alarmContent.title = "Snuze Alarm"
        alarmContent.body = "Get your ass out of bed"
        alarmContent.sound = UNNotificationSound.default()
        alarmContent.categoryIdentifier = "SNUZE_ALARM"
        
        var alarmTime = DateComponents()
        alarmTime.calendar = Calendar.current
        
        alarmTime.hour = json["hour"] as? Int
        alarmTime.minute = json["minute"] as? Int
//            print(alarmTime)
        
//        Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: alarmTime, repeats: true)
        print(trigger)
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: alarmContent, trigger: trigger)
        print(request)
        
        notificationCenter.removeAllPendingNotificationRequests()
        
        // Schedule the request with the system.
        notificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
                print(error!)
                print("THERE WAS AN ERROR ADDING THE NOTIFICATION REQUEST")
            }
        }
        result(uuidString)
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let title = notification.request.content.title
//        let body = notification.request.content.body
//
//        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "I don't wanna 😩", style: .default, handler: nil))
        
        //                self.present(alertController, animated: true, completion: nil)
//        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        return completionHandler(UNNotificationPresentationOptions.alert)
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
