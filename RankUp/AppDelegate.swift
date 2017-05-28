//
//  AppDelegate.swift
//  RankUp
//
//  Created by Omar Droubi on 12/28/16.
//  Copyright © 2016 Omar Droubi. All rights reserved.
//

//////////////////
// APP DELEGATE //
/////////////////

import UIKit
import Firebase
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    override init() {
        super.init()
        FIRApp.configure()
        // not really needed unless you really need it FIRDatabase.database().persistenceEnabled = true
    }
    
    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)
        -> Bool {

            FIRApp.configure()
            
            return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
}
