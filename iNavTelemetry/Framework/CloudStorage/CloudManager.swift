//
//  CloudManager.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 25.1.22.
//

import Foundation
import Combine

protocol FileManagerProtocol {
    func create()
    func save(file: URL)
    func fetch() -> AnyPublisher<[URL],Never>
    func clear()
}

final class CloudManager: FileManagerProtocol {

    private let fileManager: FileManager
    private var pathStorage: URL? {
        guard let url = fileManager.url(forUbiquityContainerIdentifier: nil) else {
            return nil
        }
        return url.appendingPathComponent("Documents")
    }
    private var available: Bool {
        guard let _ = fileManager.ubiquityIdentityToken else { return false }
        return true
    }

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func create() {
        guard available else { return }
        guard let pathStorage = pathStorage,
              fileManager.fileExists(atPath: pathStorage.path, isDirectory: nil),
              let _ = try? fileManager.createDirectory(at: pathStorage, withIntermediateDirectories: true, attributes: nil) else { return }
    }

    func save(file: URL) {
        guard available else { return }
        guard let pathStorage = pathStorage else { return }

        let documentURL = pathStorage.appendingPathComponent(file.lastPathComponent)

        var isDir: ObjCBool = false
        if !fileManager.fileExists(atPath: documentURL.path, isDirectory: &isDir) {
            guard let _ = try? fileManager.copyItem(at: file, to: documentURL) else { return }
        }
    }

    func fetch() -> AnyPublisher<[URL],Never> {
        guard available else {
            return Just([])
                .eraseToAnyPublisher()
        }
        
        guard let pathStorage = pathStorage else {
            return Just([])
                .eraseToAnyPublisher()
        }
        
        guard let directoryContents = try? fileManager.contentsOfDirectory(at: pathStorage, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return Just([])
                .eraseToAnyPublisher()
        }
        
        return CurrentValueSubject(directoryContents)
            .eraseToAnyPublisher()
    }

    func clear() {
        guard available else { return }
        guard let pathStorage = pathStorage,
              let files = try? fileManager.contentsOfDirectory(atPath: pathStorage.path) else { return }

        files.forEach { guard let _ = try? fileManager.removeItem(atPath: $0) else { return } }
    }
}
