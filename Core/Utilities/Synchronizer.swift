//
//  Synchronizer.swift
//  Core
//
//  Created by 디해 on 11/27/24.
//

import CryptoKit
import Foundation

public final class Synchronizer {
    private let fileManager = FileManager.default
    private let folder: URL
    
    public init(folder: URL) {
        self.folder = folder
    }
    
    public func compareToLocal(with hashes: [String: String]) -> [String: HashCondition] {
        let localHashes = collectHashes()
        var result: [String: HashCondition] = [:]
        
        localHashes.filter { hashes[$0.key] == nil }.keys.forEach {
            result[$0] = .additional
        }
        
        hashes.filter { localHashes[$0.key] == nil }.keys.forEach {
            result[$0] = .missing
        }
    
        return result
    }
    
    public func collectHashes() -> [String: String] {
        var fileHashes = [String: String]()
        
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        ) else { return [:] }
        for fileURL in fileURLs {
            guard let hash = calculateFileHash(for: fileURL) else { return [:] }
            fileHashes[fileURL.lastPathComponent] = hash
        }
        
        return fileHashes
    }
    
    private func calculateFileHash(for fileURL: URL) -> String? {
        guard let fileData = try? Data(contentsOf: fileURL) else { return nil }
        let hash = SHA256.hash(data: fileData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

@frozen public enum HashCondition: Codable {
    case missing
    case additional
}
