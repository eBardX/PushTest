import CallKit
import os.log
import PushKit
import UIKit

@UIApplicationMain
public class AppDelegate: UIResponder {

    // MARK: Public Instance Properties

    public var window: UIWindow?

    // MARK: Public Instance Methods

    public func display(_ text: String,
                        terminator: String = "\n") {
        print(text)

        os_log("%{public}s",
               log: .pushTest,
               type: .default,
               text)

        displayedText.append(text)
        displayedText.append(terminator)

        guard
            let vc = window?.rootViewController as? ViewController
            else { return }

        vc.text = displayedText
    }

    // MARK: Private Instance Properties

    private let callProvider: CXProvider
    private let pushRegistry: PKPushRegistry

    private var displayedText: String

    // MARK: Private Instance Methods

    private func _state(of application: UIApplication) -> String {
        switch application.applicationState {
        case .active:
            return "Active"

        case .background:
            return "Background"

        case .inactive:
            return "Inactive"

        @unknown default:
            return String(describing: application.applicationState)
        }
    }

    // MARK: Overridden UIResponder Initializers

    override public init() {
        let config = CXProviderConfiguration(localizedName: "Waldo")

        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.phoneNumber]
        config.supportsVideo = false

        self.callProvider = CXProvider(configuration: config)
        self.displayedText = ""
        self.pushRegistry = PKPushRegistry(queue: .main)

        super.init()

        self.callProvider.setDelegate(self,
                                      queue: .main)

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
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        display("[\(_state(of: application))] Application did finish launching, options: \(launchOptions ?? [:])")

        #if !targetEnvironment(simulator)
        application.registerForRemoteNotifications()
        #endif

        return true
    }

    public func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        display("Application did receive remote notification, payload: \(userInfo)")

        do /* defer */ { completionHandler(.newData) }

        // display payload ???
    }

    public func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        display("Application did register for remote notifications with device token \(deviceToken.hexEncodedString())")
    }

    public func application(_ application: UIApplication,
                            willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        display("[\(_state(of: application))] Application will finish launching, options: \(launchOptions ?? [:])")

        return true;
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        display("[\(_state(of: application))] Application did become active")
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        display("[\(_state(of: application))] Application did enter background")
    }

    public func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        display("[\(_state(of: application))] Application did receive memory warning")
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        display("[\(_state(of: application))] Application will enter foreground")
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        display("[\(_state(of: application))] Application will resign active")
    }

    public func applicationWillTerminate(_ application: UIApplication) {
        display("[\(_state(of: application))] Application will terminate")
    }
}

// MARK: - CXProviderDelegate

extension AppDelegate: CXProviderDelegate {
    public func providerDidBegin(_ provider: CXProvider) {
        display("Call provider did begin")
    }

    public func providerDidReset(_ provider: CXProvider) {
        display("Call provider did reset")
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
                             for type: PKPushType,
                             completion: @escaping () -> Void) {
        display("Push Registry did receive incoming push with payload \(payload.dictionaryPayload) for type \(type.rawValue)")

        guard
            type == .voIP,
            let handle = payload.dictionaryPayload["handle"] as? String,
            let uuidString = payload.dictionaryPayload["callUUID"] as? String,
            let callUUID = UUID(uuidString: uuidString)
            else { return }

        let callUpdate = CXCallUpdate()

        callUpdate.remoteHandle = CXHandle(type: .phoneNumber,
                                           value: handle)

        callProvider.reportNewIncomingCall(with: callUUID,
                                           update: callUpdate) { _ in
                                            completion()
        }
    }

    public func pushRegistry(_ registry: PKPushRegistry,
                             didUpdate credentials: PKPushCredentials,
                             for type: PKPushType) {
        display("Push Registry did update push token \(credentials.token.hexEncodedString()) for type \(type.rawValue)")
    }
}

internal extension OSLog {
    static let pushTest = OSLog(subsystem: "com.xesticode.PushTest",
                                category: "PushTest")
}
