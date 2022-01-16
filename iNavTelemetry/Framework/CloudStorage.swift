//
//  CloudStorage.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/27/21.
//

import Foundation

final class CloudStorage: ObservableObject {
    
    @Published private(set) var logs: [URL] = []
    
    private var iCloudAvailable: Bool {
        guard let _ = FileManager.default.ubiquityIdentityToken else { return false }
        return true
    }
    
    // MARK: - Initialization
    init() {
        createDirectory()
    }
    
    // MARK: - Private Methods
    private func pathCloudStorage() -> URL? {
        guard let url = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            return nil
        }
        return url.appendingPathComponent("Documents")
    }
    private func createDirectory(){
        guard iCloudAvailable else { return }
        guard let iCloudDocumentsURL = pathCloudStorage(),
              FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil),
              let _ = try? FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil) else {
                  print("Error in creating document folder")
                  return
              }
    }
    
    // MARK: - Internal Methods
    func saveFileToiCloud(_ fileURL: URL) {
        guard iCloudAvailable else { return }
        guard let cloudStorage = pathCloudStorage() else { return }
        let iCloudDocumentsURL = cloudStorage.appendingPathComponent(fileURL.lastPathComponent)
        
        var isDir: ObjCBool = false
        if !FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
            guard let _ = try? FileManager.default.copyItem(at: fileURL, to: iCloudDocumentsURL) else { return }
        }
    }
    func getLogs() {
        guard iCloudAvailable else { return }
        
        guard let cloudStorage = pathCloudStorage(),
              let directoryContents = try? FileManager.default.contentsOfDirectory(at: cloudStorage, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { return }
        
        self.logs = directoryContents
            .filter {
                let nameOfFile = $0.lastPathComponent
                if let _ = nameOfFile.rangeOfCharacter(from: .decimalDigits.inverted), !nameOfFile.isEmpty {
                    return false
                }
                return true
            }
            .sorted {
                if let first = Int($0.lastPathComponent),
                   let second = Int($1.lastPathComponent) {
                    return first > second
                }
                return false
            }
    }
    func cleanDatabase() {
        guard iCloudAvailable else { return }
        logs.forEach { guard let _ = try? FileManager.default.removeItem(atPath: $0.path) else { return } }
    }
}
