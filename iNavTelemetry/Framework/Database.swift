//
//  Database.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/31/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import SwiftUI

final class Database: ObservableObject {
    
    @Published private(set) var logs: [URL] = []
    
    private var jsonDatabase: [LogTelemetry] = []
    private var nameFile: String?
    private var active = false
    private var lastUpdateLocation = Date()
    
    // MARK: - Initialization
    init() {
        self.nameFile = generateName()
        self.jsonDatabase = []
        self.active = false
    }
    
    // MARK: - Private Methods
    private func pathDatabase(fileName: String?) -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let name = fileName else {
            return nil
        }
        return documentsURL.appendingPathComponent(name)
    }
    private func generateName() -> String {
        return "\(Int(NSDate.now.timeIntervalSince1970))"
    }
    
    // MARK: - Internal Methods
    func saveTelemetryData(packet: LogTelemetry) {
        let dateComponent = Calendar.current.dateComponents([.second], from: lastUpdateLocation, to: Date())
        guard let second = dateComponent.second else { return }
        if second > 1 {
            lastUpdateLocation = Date()
            jsonDatabase.append(packet)
        }
    }
    func startLogging() {
        nameFile = generateName()
        jsonDatabase = []
        active = true
    }
    func cleanDatabase() {
        logs.forEach { guard let _ = try? FileManager.default.removeItem(atPath: $0.path) else { return } }
    }
    func stopLogging() -> URL? {
        if !active { return nil }
        active = false
        
        guard let jsonData = try? JSONEncoder().encode(jsonDatabase),
              let jsonString = String(data: jsonData, encoding: .utf8),
              let pathFile = pathDatabase(fileName: nameFile),
              let _ = try? jsonString.write(toFile: pathFile.path, atomically: true, encoding: .utf8) else {
                  return nil
              }
        return pathFile
    }
    func getLogs() {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let directoryContents = try? FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                                   includingPropertiesForKeys: nil,
                                                                                   options: [.skipsHiddenFiles])
        else {
            return
        }
        
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
    static func toName(timestamp: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMM d [hh:mm]"
        let date = Date(timeIntervalSince1970: timestamp)
        return dateFormatter.string(from: date)
    }
}
