import FirebaseCore
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if DEBUG
    enableFirebaseAnalyticsDebugMode()
    #endif
    // Load GoogleService-Info.plist before Dart initializes plugins.
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  #if DEBUG
  private func enableFirebaseAnalyticsDebugMode() {
    // DebugView requires Analytics debug mode before Firebase initializes.
    // flutter run may not pass -FIRDebugEnabled from the Xcode scheme.
    let debugDefaults = UserDefaults.standard
    debugDefaults.set(true, forKey: "/google/firebase/debug_mode")
    debugDefaults.set(true, forKey: "/google/measurement/debug_mode")
    debugDefaults.synchronize()
  }
  #endif

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
