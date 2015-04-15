//
//  AppDelegate.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 09/03/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {

        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        //let rootViewController: ViewController = ViewController()
        let rootViewController: ViewControllerLogin = ViewControllerLogin()
        let navigationController: UINavigationController = UINavigationController(rootViewController: rootViewController)
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
        navigationController.setNavigationBarHidden(true, animated: false)
        
        return true
        
        /*
        //Instantiate the first viewcontroller
        let vc = ViewController()
        //Create navigation controller with viewcontroller as root
        var navController: UINavigationController = UINavigationController(rootViewController: vc)
        //Hide the navigation bar in the navigation controller
        navController.navigationBarHidden = true
        //Set navcontroller as root view in window (will then deal with that from now on)
        self.window!.rootViewController = navController
        
        return true
        */
        
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

