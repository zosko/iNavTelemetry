//
//  CloudStorage.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/27/21.
//

import Foundation
import Combine

final class CloudStorage: ObservableObject {
    
    @Published var logs: [URL] = []

    private let cloudProtocol: FileManagerProtocol

    // MARK: - Initialization
    init(cloudProtocol: FileManagerProtocol = CloudManager()) {
        self.cloudProtocol = cloudProtocol

        self.create()
    }
    
    // MARK: - Internal methods
    func save(file: URL) {
        cloudProtocol.save(file: file)
    }

    func fetch() {
        cloudProtocol.fetch()
            .map({ urls in
                urls.filter { url in
                    url.filterFile()
                }
                .sortFiles()
            })
            .assign(to: &$logs)
    }

    func clear() {
        cloudProtocol.clear()
    }
    
    // MARK: - Private methods
    private func create() {
        cloudProtocol.create()
    }
}

extension Array where Element == URL {
    func sortFiles() -> [URL] {
        sorted {
            if let first = Int($0.lastPathComponent),
               let second = Int($1.lastPathComponent) {
                return first > second
            }
            return false
        }
    }
}

extension URL {
    func filterFile() -> Bool {
        let nameOfFile = self.lastPathComponent
        if let _ = nameOfFile.rangeOfCharacter(from: .decimalDigits.inverted), !nameOfFile.isEmpty {
            return false
        }
        return true
    }
}
