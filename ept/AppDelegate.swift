//
//  AppDelegate.swift
//  ept
//
//  Created by 临时用户 on 2017/2/8.
//  Copyright © 2017年 临时用户. All rights reserved.
//

import UIKit

let ZIP_PATH = Bundle.main.path(forResource: "ept", ofType: "zip");
let DOC_PATH = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        check();
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
extension AppDelegate{
    fileprivate func check(){
        debugPrint("start check ")
        let curVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let v = UserDefaults.standard.value(forKey: "version")
        var version = "";
        if(v != nil ){
            version = v as! String
        }
        debugPrint("version:"+version)
        debugPrint("curversion:"+curVersion!)
        //FileManager.default.fileExists(atPath: DOC_PATH+"/ept")
        if(curVersion!>version){
            do{
                debugPrint("start unzip ")
            try SSZipArchive.unzipFile(atPath: ZIP_PATH!, toDestination: DOC_PATH, overwrite: true, password: nil)
                UserDefaults.standard.set(curVersion, forKey: "version")
            }catch let err{
                debugPrint(err)}
        }
    }
    
}

