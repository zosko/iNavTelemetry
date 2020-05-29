//
//  AppDelegate.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 5/28/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        return true
    }

}

