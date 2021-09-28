//
//  Database.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/31/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import SwiftUI

class Database: NSObject, ObservableObject {
    
    @Published var logs: [URL] = []
    
    private var jsonDatabase : [TelemetryManager.LogTelemetry] = []
    private var nameFile : String!
    private var active = false
    private var lastUpdateLocation = Date()
    
    //MARK: - Initialization
    override init(){
        super.init()
        
        self.nameFile = generateName()
        self.jsonDatabase = []
        self.active = false
    }
    
    //MARK: - Private Methods
    private func pathDatabase(fileName: String) -> URL{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsURL?.appendingPathComponent(fileName)
        return fileURL!
    }
    
    //MARK: - Internal Methods
    func saveTelemetryData(packet : TelemetryManager.LogTelemetry){
        let dateComponent = Calendar.current.dateComponents([.second], from: lastUpdateLocation, to: Date())
        guard let second = dateComponent.second else { return }
        if second > 1 {
            lastUpdateLocation = Date()
            jsonDatabase.append(packet)
        }
    }
    func generateName() ->String{
        return "\(Int(NSDate.now.timeIntervalSince1970))"
    }
    func startLogging(){
        nameFile = generateName()
        jsonDatabase = []
        active = true
    }
    func cleanDatabase(){
        for logs in self.logs {
            do{
                try FileManager.default.removeItem(atPath: logs.path)
            }catch{
                print(error)
            }
        }
    }
    func stopLogging() -> URL? {
        if !active { return nil }
        
        do {
            active = false
            let jsonData = try JSONEncoder().encode(jsonDatabase)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            try jsonString.write(toFile: pathDatabase(fileName: nameFile).path, atomically: true, encoding: .utf8)
            return pathDatabase(fileName: nameFile)
        } catch {
            return nil
        }
    }
    func getLogs(){
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        self.logs = directoryContents
            .filter { url in
                let nameFile = url.lastPathComponent
                return !nameFile.isEmpty && nameFile.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
            }
            .sorted{ Int($0.lastPathComponent)! > Int($1.lastPathComponent)! }
    }
    static func toName(timestamp : Double) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMM d [hh:mm]"
        let date = Date(timeIntervalSince1970: timestamp)
        return dateFormatter.string(from: date)
    }
}
