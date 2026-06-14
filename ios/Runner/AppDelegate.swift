import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    #if DEBUG
    // DebugView requires Analytics debug mode before Firebase initializes.
    // flutter run may not pass -FIRDebugEnabled from the Xcode scheme; persist both
    // keys the measurement SDK checks (see FirebaseCore FIRLogger.m).
    let debugDefaults = UserDefaults.standard
    debugDefaults.set(true, forKey: "/google/firebase/debug_mode")
    debugDefaults.set(true, forKey: "/google/measurement/debug_mode")
    debugDefaults.synchronize()
    #endif
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
