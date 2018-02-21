import PushKit
import UIKit

@UIApplicationMain
public class AppDelegate: UIResponder {

    // MARK: Public Instance Properties

    public var window: UIWindow?

    // MARK: Public Instance Methods

    public func display(_ text: String,
                        terminator: String = "\n") {
        displayedText.append(text)
        displayedText.append(terminator)

        guard
            let vc = window?.rootViewController as? ViewController
            else { return }

        vc.text = displayedText
    }

    // MARK: Private Instance Properties

    private let pushRegistry: PKPushRegistry

    private var displayedText: String

    // MARK: Overridden UIResponder Initializers

    override public init() {
        self.displayedText = ""
        self.pushRegistry = PKPushRegistry(queue: .main)

        super.init()

        self.pushRegistry.delegate = self
        self.pushRegistry.desiredPushTypes = [.voIP]
    }
}

// MARK: - UIApplicationDelegate

extension AppDelegate: UIApplicationDelegate {
    public func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
        display("Application did fail to register for remote notifications, error: \(error)")
    }

    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        display("Application did finish launching, options: \(launchOptions ?? [:])")

        application.registerForRemoteNotifications()

        return true
    }

    public func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        display("Application did receive remote notification, payload: \(userInfo)")

        defer { completionHandler(.newData) }

        // display payload ???
    }

    public func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        display("Application did register for remote notifications with device token \(deviceToken.hexEncodedString())")
    }

    public func application(_ application: UIApplication,
                            willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        display("Application will finish launching, options: \(launchOptions ?? [:])")

        return true;
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        display("Application did become active")
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        display("Application did enter background")
    }

    public func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        display("Application did receive memory warning")
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        display("Application will enter foreground")
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        display("Application will resign active")
    }

    public func applicationWillTerminate(_ application: UIApplication) {
        display("Application will terminate")
    }
}

// MARK: - PKPushRegistryDelegate

extension AppDelegate: PKPushRegistryDelegate {
    public func pushRegistry(_ registry: PKPushRegistry,
                             didInvalidatePushTokenFor type: PKPushType) {
        display("Push Registry did invalidate push token for type \(type.rawValue)")
    }

    public func pushRegistry(_ registry: PKPushRegistry,
                             didReceiveIncomingPushWith payload: PKPushPayload,
                             for type: PKPushType) {
        display("Push Registry did receive incoming push with payload \(payload.dictionaryPayload) for type \(type.rawValue)")
    }

    public func pushRegistry(_ registry: PKPushRegistry,
                             didUpdate credentials: PKPushCredentials,
                             for type: PKPushType) {
        display("Push Registry did update push token \(credentials.token.hexEncodedString()) for type \(type.rawValue)")
    }
}
