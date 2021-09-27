//
//  CloudStorage.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/27/21.
//

import Foundation

class CloudStorage: NSObject, ObservableObject {
    
    @Published var logs: [URL] = []
    
    override init() {
        super.init()
        createDirectory()
    }
    
    private func isICloudContainerAvailable() -> Bool {
        return FileManager.default.ubiquityIdentityToken == nil ? false : true
    }
    private func createDirectory(){
        if isICloudContainerAvailable() {
            if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                    do {
                        try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                    }
                    catch {
                        print("Error in creating document folder")
                    }
                }
            }
        }
        else {
            print("Not logged into iCloud")
        }
    }
    
    func saveFileToiCloud(_ fileURL: URL) {
        if isICloudContainerAvailable() {
            guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(fileURL.lastPathComponent) else { return }
            var isDir: ObjCBool = false
            if !FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
                do {
                    try FileManager.default.copyItem(at: fileURL, to: iCloudDocumentsURL)
                }
                catch {
                    print("Error in copy item")
                }
            }
        }
        else {
            print("Not logged into iCloud")
        }
    }
    func getLogs() {
        if isICloudContainerAvailable() {
            guard let documentsUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else { return }
            
            let directoryContents = try! FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            self.logs = directoryContents
                .filter { url in
                    let nameFile = url.lastPathComponent
                    return !nameFile.isEmpty && nameFile.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
                }
                .sorted{ Int($0.lastPathComponent)! > Int($1.lastPathComponent)! }
        }
        else {
            print("Not logged into iCloud")
        }
    }
    func cleanDatabase() {
        if isICloudContainerAvailable() {
            for logs in self.logs {
                do{
                    try FileManager.default.removeItem(atPath: logs.path)
                }catch{
                    print(error)
                }
            }
        }
        else {
            print("Not logged into iCloud")
        }
    }
}
