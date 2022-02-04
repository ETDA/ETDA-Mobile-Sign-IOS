//
//  AppDelegate.swift
//  tedasign
//
//  Created by Mee on 28/6/2564 BE.
//

import UIKit
import CoreData
import GoogleSignIn
import KeychainAccess
//@main
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var keychains = Keychain(service: "com.etda.tedasign.TEDASign")
//        .synchronizable(true)
        .accessibility(.always)
//        .accessibility(.afterFirstUnlock, authenticationPolicy: .userPresence)
//        .authenticationPrompt("กรุณายืนยันตัวตนของท่าน")
    static var isFirst = true
    static var isAuthFirst = true

    static var isAuth = false
    static var isFaceFirst = true

    static var navigationBarSize = 80
    static var signInConfig = GIDConfiguration.init(clientID: "122602631742-skjdl0ekjj4begr2928spag01nfsivo0.apps.googleusercontent.com")
    var window: UIWindow?
    
    static var qrcode = ""
    static var shareFilePath = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("shared.p12")
    static var importingKeyFromShareFile = false
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
      //bookTableViewController.tableView.reloadData()
      return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        printDocumentsDirectory()
        let userdefaults = UserDefaults.standard
        if userdefaults.object(forKey: "isAuthFirst") != nil{
        } else {
           userdefaults.set(true, forKey: "isAuthFirst")
        }
        if userdefaults.object(forKey: "isAuth") != nil{
            
        } else {
           userdefaults.set(false, forKey: "isAuth")
        }
        //GIDSignIn.sharedInstance().clientID = "38584293763-pv320l884egmt4984hjcphku3bai8imk.apps.googleusercontent.com"
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("ABC")
        var handled: Bool
          handled = GIDSignIn.sharedInstance.handle(url)
          if handled {
            return true
          }
          return false
        //return GIDSignIn.sharedInstance.handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    private func printDocumentsDirectory() {
        let fileManager = FileManager.default
        if let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last {
            print("Documents directory: \(documentsDir.absoluteString)")
        } else {
            print("Error: Couldn't find documents directory")
        }
    }

    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "tedasign")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
  

}

