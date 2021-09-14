//
//  Database.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/31/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

import SwiftUI

class Database: NSObject {
    var jsonDatabase : [TelemetryManager.LogTelemetry] = []
    var nameFile : String!
    var active = false
    
    static var shared: Database = {
        let instance = Database()
        
        instance.nameFile = instance.generateName()
        instance.jsonDatabase = []
        instance.active = false
        return instance
    }()
    
    private func pathDatabase(fileName: String) -> URL{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsURL?.appendingPathComponent(fileName)
        return fileURL!
    }
    func saveTelemetryData(packet : TelemetryManager.LogTelemetry){
        jsonDatabase.append(packet)
    }
    func removeFile(fileName: URL) -> Void{
        do{
            try FileManager.default.removeItem(at: fileName)
        }catch{
            print(error)
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
        for logs in Database.getLogs() {
            do{
                try FileManager.default.removeItem(atPath: logs.path)
            }catch{
                print(error)
            }
        }
    }
    func stopLogging(){
        active = false
        
        let jsonData = try! JSONEncoder().encode(jsonDatabase)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        try! jsonString.write(toFile: pathDatabase(fileName: nameFile).path, atomically: true, encoding: .utf8)
    }
    static func getLogs() -> [URL]{
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        return directoryContents.filter { url in
            let nameFile = url.lastPathComponent
            return !nameFile.isEmpty && nameFile.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
    static func toName(timestamp : Double) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMM d [hh:mm]"
        let date = Date(timeIntervalSince1970: timestamp)
        return dateFormatter.string(from: date)
    }
    func openLog(urlLog : URL){
        let jsonData = try! Data(contentsOf: urlLog)
        let logData = try! JSONDecoder().decode([TelemetryManager.LogTelemetry].self, from: jsonData)
    }
}
