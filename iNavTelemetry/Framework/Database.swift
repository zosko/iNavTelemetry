//
//  Database.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/31/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif

class Database: NSObject {
    var jsonDatabase : [SmartPortStruct] = []
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
    func saveTelemetryData(packet : SmartPortStruct){
        if !active { return }
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
        for logs in getLogs() {
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
    func getLogs() -> [URL]{
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        return directoryContents.filter { url in
            let nameFile = url.lastPathComponent
            return !nameFile.isEmpty && nameFile.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
}
