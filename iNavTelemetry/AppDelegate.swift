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
        
        SocketComunicator.shared.socketConnectionSetup()
        
        NSSetUncaughtExceptionHandler { exception in
            let appVersion = CrashReport.appVersion() + " build " + CrashReport.buildVersion()
            let versionDevice = UIDevice.current.systemVersion
            let modelDevice = UIDevice.current.model
            
            var strLog = try! String(contentsOfFile: CrashReport.crashReportPath())
            
            var strItem = "<html><head><title>Report Crash bug</title></head><body>";
            strItem.append("<b>Application Version:</b> \(appVersion)<br />")
            strItem.append("<b>Device version:</b> \(versionDevice)<br />")
            strItem.append("<b>Device model:</b> \(modelDevice)<br />")
            strItem.append("<b>Crash Reason:</b><br /> <pre>\(exception)</pre><br />")
            strItem.append("<b>Crash Description:</b><br /><pre>\(exception.debugDescription)</pre><br />")
            strItem.append("</body></html>")
            
            strLog.append(strItem)
            try! strLog.write(toFile: CrashReport.crashReportPath(), atomically: true, encoding: .utf8)
        }
        
        return true
    }

}

