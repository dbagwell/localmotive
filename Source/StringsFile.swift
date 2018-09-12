//
//  StringsFile.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-03-27.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

class StringsFile: NSObject {
    
    // MARK: - Errors
    
    enum CreationError: Error {
        case fileExists
    }
    
    
    // MARK: - Constants
    
    private static let keyAndStringPattern = "\\\"(.*)\\\" *= *\\\"(.*)\\\";"
    private static let commentPattern = "\\/\\*\\s*(.*\\S)\\s*\\*\\/"
    private static let pattern = "(?:" + commentPattern + "\\s*" + ")?" + keyAndStringPattern
    
    
    // MARK: - Properties
    
    var url: URL {
        didSet {
            
        }
    }
    
    private(set) var languageCode: String
    
    var keyedStrings = [String: String]()
    var keyedComments = [String: String]()
    
    var lastModifiedDate: Date {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: self.url.path)
            return attributes[.modificationDate] as? Date ?? Date()
        } catch {
            return Date()
        }
    }
    
    
    // MARK: - Init
    
    init(url: URL, createNew: Bool = false) throws {
        self.url = url
        self.languageCode = url.deletingLastPathComponent().deletingPathExtension().lastPathComponent
        
        if createNew {
            if FileManager.default.fileExists(atPath: url.path) {
                throw CreationError.fileExists
            }
            
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try "".write(to: url, atomically: true, encoding: .utf8)
            
        } else {
            let contents = try String(contentsOfFile: url.path, encoding: .utf8)
            let nsContents = contents as NSString
            let regex = try! NSRegularExpression(pattern: StringsFile.pattern, options: [])
            let matches = regex.matches(in: contents, options: [], range: NSRange(location: 0, length: contents.count))
            
            for match in matches {
                let key = nsContents.substring(with: match.range(at: match.numberOfRanges-2))
                var string = nsContents.substring(with: match.range(at: match.numberOfRanges-1))
                string = string.replacingOccurrences(of: "\n", with: "\\n")
                string = string.replacingOccurrences(of: "\t", with: "\\t")
                self.keyedStrings[key] = string
                
                if match.range(at: match.numberOfRanges-3).length > 0 {
                    self.keyedComments[key] = nsContents.substring(with: match.range(at: match.numberOfRanges-3))
                }
            }
        }
        
        super.init()
    }
    
    
    // MARK: - Methods
    
    func save() throws {
        var lines = [String]()
        
        for (key, value) in self.keyedStrings.sorted(by: { $0.key.strictCaseInsensitiveCompare($1.key) == .orderedAscending }) {
            if let comment = self.keyedComments[key] {
                lines.append("/* \(comment) */")
            }
            
            var value = value.replacingOccurrences(of: "\n", with: "\\n")
            value = value.replacingOccurrences(of: "\t", with: "\\t")
            lines.append("\"\(key)\" = \"\(value)\";")
        }
        
        let contents = lines.joined(separator: "\n")
        try contents.write(to: self.url, atomically: true, encoding: .utf8)
    }
    
    func setStringsToEmpty() {
        for key in Array(self.keyedStrings.keys) {
            self.keyedStrings[key] = ""
        }
    }
}
