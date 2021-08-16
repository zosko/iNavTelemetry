//
//  CrashReport.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 8/16/21.
//  Copyright © 2021 Bosko Petreski. All rights reserved.
//

import UIKit

class CrashReport: NSObject {
    
    static func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    static func buildVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    static func crashReportPath() -> String{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let urlFilePath = documentsURL?.appendingPathComponent("crash_report.html").path
        
        if !FileManager.default.fileExists(atPath: urlFilePath!) { //if does not exist
            FileManager.default.createFile(atPath: urlFilePath!, contents: nil, attributes: [:])
        }
        return urlFilePath!
    }
    static func anythingForReport(_ controller: UIViewController){
        let strLog = try! String(contentsOfFile: CrashReport.crashReportPath())
        
        if strLog.isEmpty { return }
        
        let alertController = UIAlertController(title: "Report crash?", message: "Send on github or to email: bosko.petreski@gmail.com", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let file = URL(fileURLWithPath: CrashReport.crashReportPath())
                let activityViewController = UIActivityViewController(activityItems: [file], applicationActivities: nil)
                
                activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    if completed {
                        try! "".write(toFile: CrashReport.crashReportPath(), atomically: true, encoding: .utf8)
                    }
                }
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceRect = CGRect(x: controller.view.frame.size.width / 2,
                                                          y: controller.view.frame.size.height / 2,
                                                          width: 0, height: 0)
                    popoverController.sourceView = controller.view
                    popoverController.permittedArrowDirections = .down
                }
                controller.present(activityViewController, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            try! "".write(toFile: CrashReport.crashReportPath(), atomically: true, encoding: .utf8)
        }))
        controller.present(alertController, animated: true, completion: nil)
    }
}
