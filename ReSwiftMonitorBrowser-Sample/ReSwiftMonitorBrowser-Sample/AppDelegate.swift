import UIKit
import ReSwift
import ReSwiftMonitor

var middleware: [Middleware<AppState>] = {
    let monitorMiddleware = MonitorMiddleware.make(configuration: Configuration())
    let browserMiddleware = BrowserMiddleware.make()
    return [monitorMiddleware, browserMiddleware]
}()

let store = Store<AppState>(reducer: AppState.reducer(), state: AppState(), middleware: middleware)


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

