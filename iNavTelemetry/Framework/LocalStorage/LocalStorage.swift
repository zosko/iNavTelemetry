//
//  Database.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/31/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import SwiftUI
import Combine

final class LocalStorage {
    
    private var jsonDatabase: [LogTelemetry] = []
    private var nameFile: String = "\(Int(NSDate.now.timeIntervalSince1970))"
    private var active = false
    private var lastUpdateTimestamp = Date()
    private let loggerManager: DataLoggerProtocol
    
    // MARK: - Initialization
    init(loggerManager: DataLoggerProtocol = DataLoggerManager()) {
        self.loggerManager = loggerManager
    }
    
    // MARK: - Private Methods
    private func generateName() -> String {
        return "\(Int(NSDate.now.timeIntervalSince1970))"
    }
    
    // MARK: - Internal Methods
    func save(packet: LogTelemetry) {
        let dateComponent = Calendar.current.dateComponents([.second], from: lastUpdateTimestamp, to: Date())
        guard let second = dateComponent.second else { return }
        if second > 1 {
            lastUpdateTimestamp = Date()
            jsonDatabase.append(packet)
        }
    }
    func start() {
        nameFile = generateName()
        jsonDatabase = []
        active = true
    }
    func clear() {
        loggerManager.clean()
    }
    func stop() -> URL? {
        if !active { return nil }
        active = false
        
        guard let jsonData = try? JSONEncoder().encode(jsonDatabase),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return nil
        }
        
        jsonDatabase = []
        return loggerManager.save(data: jsonString, name:nameFile)
    }
    func fetch() -> AnyPublisher<[URL], Never> {
        loggerManager.fetch()
            .map({ urls in
                urls.filter { url in
                    url.filterFile()
                }
                .sortFiles()
            })
            .eraseToAnyPublisher()
    }
    static func toName(timestamp: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMM d [hh:mm]"
        let date = Date(timeIntervalSince1970: timestamp)
        return dateFormatter.string(from: date)
    }
}
