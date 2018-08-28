import UIKit
import Magic

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Задаём настройки соединения с Github-приложением разработчика
    GithubService.configure(clientID: "1f6c1aebd1e66e6f3363", clientSecret: "b96f7e68dcc37f093404fd3bacb5d69763f69f2f")
    
    // Процесс попытки открытия окна авторизации и получения доступа к данным пользователя
    do {
      try GithubService.shared.requestAuthorization(scopes: [.user, .gist])
    }
    catch {
      magic("Error: \(error)")
    }
    
    return true
  }
  
  /// Обработка входящего запроса из Safari в случае успешной авторизации
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    if let sendingApp = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String {
      if sendingApp == "com.apple.mobilesafari" {
        // Здесь мы сохраняем токен внутри нашего сервисного инстанса (синглтон)
        GithubService.shared.requestAuthToken(url: url)
      }
    }
    
    return true
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
