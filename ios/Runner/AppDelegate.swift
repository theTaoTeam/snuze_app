import UIKit
import Flutter
import Foundation
import MediaPlayer
import UserNotifications
import Stripe
import Firebase
import os.log

@available(iOS 10.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, AVAudioPlayerDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    private var flutterViewController:FlutterViewController!
    private var alarmStartedMessageChannel:FlutterBasicMessageChannel!
    var appLaunchTime = Date()
    var alarmTimer:Timer?
    var player:AVAudioPlayer?
    var audioStartTime:Date?

    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    Messaging.messaging().delegate = self
    getCurrentFCMToken()
    // Set launch date for time-related functionality
    appLaunchTime = Date()
    
    // Initialize Flutter
    setupFlutter()
    
    // Setup audio environment
    setupAudioEnvironment()
    
    // Setup observers
    setupObservers()
    
    // Get notifications permission
    setupNotificationOptions()

    // Setup Firebase
//    FirebaseApp.configure()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions);
    }
    override init() {
        // Firebase Init
        FirebaseApp.configure()
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
    //MARK:- FIREBASE MESSAGING DELEGATE
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("RECEIVED FCM REGISTRATION TOKEN")
    }
    
    //MARK:- APP DELEGATE METHODS
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        print("App did enter background.")
        
        // If alarm is set, alert user with a local notificaiton that the app needs to remain open
//        if let alarmTimer = alarmTimer, alarmTimer.fireDate > Date() {
//            let content = UNMutableNotificationContent()
//            content.title = "⏰ Snüze was Closed"
//            content.body = "Don't forget Snüze needs to remain open for your alarms to work properly"
//            content.sound = UNNotificationSound.default()
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//
//            let identifier = "AppMustRemainOpenNotification"
//            let request = UNNotificationRequest(identifier: identifier,
//                                                content: content,
//                                                trigger: trigger)
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
//                if let error = error {
//                    print("Couldn't schedule notification. Error: \(error)")
//                }
//                else {
//                    print("Scheduled local alert notification")
//                }
//            })
//        }
//        else {
//            print("Alarm is not set.")
//        }
    }
    
    
    func getCurrentFCMToken() -> String? {
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "No current token")")
        return token
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("did receive remote firebase message")
    }

    
    
    //MARK:- FLUTTER
    
    private func setupFlutter() {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        self.flutterViewController = controller
        
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
        
        alarmStartedMessageChannel = FlutterBasicMessageChannel(
            name: "snuze.app/alarmMessage",
            binaryMessenger: controller,
            codec: FlutterStringCodec.sharedInstance())

        GeneratedPluginRegistrant.register(with: self)
    }
    
    private func cancelAlarm(result: FlutterResult, args: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        
        // Stop audio and cancel alarm
        stopAlarmAudio()
        alarmTimer?.invalidate()
        alarmTimer = nil
        
        // Enable auto-lock
        setAutoLockMode(disabled: false)
        
        print("CANCELLED ALARM")
    }
    
    
    //MARK:- OBSERVERS SETUP
    
    func setupObservers() {
        // Setup volume observer
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(true)
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    
    //MARK:- OBSERVER HANDLERS
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            volumeDidChange()
        }
    }
    
    func volumeDidChange() {
        print("Volume changed to \(AVAudioSession.sharedInstance().outputVolume)")
        
        // If alarm is sounding, snooze alarm
        if player?.isPlaying == true {
            snoozeAlarm()
        }
    }

    
    //MARK:- NOTIFICATIONS SETUP
    
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
            authorizationOptions = [.alert, .sound]
        } else {
            // Fallback on earlier versions
            authorizationOptions = [.alert, .sound] // Critical alert only available in iOS 12+
        }
        
        notificationCenter.requestAuthorization(options: authorizationOptions)
        { (granted, error) in
            // Enable or disable features based on authorization.
            notificationCenter.delegate = self
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            print(settings.authorizationStatus == .authorized)
            guard settings.authorizationStatus == .authorized else {return}
        }
    }
    
    
    //MARK:- ALARM
    
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
        
        setAlarmForDeviceAlwaysOnMode(hour: hour, minute: minute)
        //setAlarmWithMultipleNotifications(hour: hour, minute: minute)
        
        return;
    }
    
    private func setAutoLockMode(disabled:Bool) {
        UIApplication.shared.isIdleTimerDisabled = disabled
    }
    
    private func setAlarmForDeviceAlwaysOnMode(hour: Int, minute: Int) {
        setAutoLockMode(disabled: true)
        
        let now = Date()
        
        var alarmTime = DateComponents()
        alarmTime.calendar = Calendar.current
        alarmTime.day = Calendar.current.component(.day, from: now)
        alarmTime.month = Calendar.current.component(.month, from: now)
        alarmTime.year = Calendar.current.component(.year, from: now)
        alarmTime.hour = hour
        alarmTime.minute = minute
        alarmTime.second = 0
        
        var secondsTillAlarm:TimeInterval = 0
        
        if var date = Calendar.current.date(from: alarmTime) {
            // If alarm time is in the past for today, add 24 hours
            if date < now {
                date = date.addingTimeInterval(24 * 60 * 60)
            }
            
            secondsTillAlarm = date.timeIntervalSince(now)
        }
        
        // Cancel a previously set alarm
        if alarmTimer != nil {
            print("Canceling previous alarm with fire date \(alarmTimer!.fireDate)")
            alarmTimer!.invalidate()
        }
        
        stopAlarmAudio()
        
        print("Setting alarm to sound in \(secondsTillAlarm) seconds")
        if player == nil {
            prepareAlarmAudio()
        }
        
        // Set a timer to fire at the chosen alarm time
        alarmTimer = Timer.scheduledTimer(withTimeInterval: secondsTillAlarm, repeats: false) { (timer) in
            self.startAlarmWithAudio()
        }
    }
    
    private func snoozeAlarm() {
        stopAlarmAudio()
        
        // Set a timer to fire at the chosen alarm time
        alarmTimer?.invalidate()
        let snoozeSeconds:TimeInterval = 60 * 9
        
        print("Snoozing alarm. Will sound again in \(snoozeSeconds) seconds.")
        
        alarmTimer = Timer.scheduledTimer(withTimeInterval: snoozeSeconds, repeats: false) { (timer) in
            self.startAlarmWithAudio()
        }
    }
    
    private func startAlarmWithAudio() {
        print("ALARM IS GOING OFF NOW!!!!!!!!!!!!!!!!!!!!!!!!!!!")

        // Send message to Dart and receive reply
        alarmStartedMessageChannel.sendMessage(true) {(reply: Any?) -> Void in
            os_log("%@", type: .info, reply as! String)
        }
        
        self.playAlarmAudio()
        self.alarmTimer = nil
    }
    
    
    //MARK:- AUDIO
    
    private func setupAudioEnvironment() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print("Could not set audio category. Error: \(error)")
        }
    }
    
    private func prepareAlarmAudio() {
        if let audioURL = Bundle.main.url(forResource: "song", withExtension: "caf") {
            if player != nil {
                return
            }
            else {
                do {
                    player = try AVAudioPlayer(contentsOf: audioURL)
                    player!.prepareToPlay()
                    player!.delegate = self
                }
                catch {
                    print("Error preparing audio. Error: \(error)")
                }
            }
        }
    }
    
    private func playAlarmAudio() {
        if player == nil {
            prepareAlarmAudio()
        }
        
        player?.play()
        audioStartTime = Date()
    }
    
    private func stopAlarmAudio() {
        player?.stop()
        player?.currentTime = 0
    }
    
    
    //MARK:- AVAUDIOPLAYER DELEGATE
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let maxAlarmPlayingTime:TimeInterval = 60 * 10
        if let startTime = audioStartTime, Date().timeIntervalSince(startTime) < maxAlarmPlayingTime {
            player.play()
        }
        else {
            alarmTimer = nil
        }
    }
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Debug print full message
        print(userInfo)
        print("*********************************************************")
        print("TRIGGERED ALARM")
        DispatchQueue.main.async {
            self.playAlarmAudio()
        }
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
//        if let messageID = userInfo[//gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
        print("*********************************************************")
        print("TRIGGERED ALARM FETCH")
        DispatchQueue.main.async {
            self.playAlarmAudio()
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
    }
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError. error: \(error)")
    }
    
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
