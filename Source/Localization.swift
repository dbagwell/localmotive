//
//  Localization.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-04-06.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

class Localization: NSObject {
    
    // MARK: - Enums
    
    enum Error: Swift.Error {
        case filesNotFound
    }
    
    
    // MARK: - Properties
    
    var containingDirectory: URL
    var fileName: String
    var stringsFiles = [StringsFile]()
    var localStrings = [LocalString]() {
        didSet {
            self.localStrings.sort(by: { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending })
        }
    }
    
    
    // MARK: - Init
    
    init(containingDirectory: URL, fileName: String) throws {
        self.containingDirectory = containingDirectory
        self.fileName = fileName
        
        let urls = try FileManager.default.contentsOfDirectory(at: containingDirectory, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants)
        
        for url in urls where url.pathExtension == "lproj" {
            if let localizedStringsURL = url.appendingPathComponentIfExists(fileName) {
                self.stringsFiles.append(try StringsFile(url: localizedStringsURL))
            }
        }
        
        if stringsFiles.isEmpty {
            throw Localization.Error.filesNotFound
        }
        
        for stringsFile in self.stringsFiles {
            for (key, string) in stringsFile.keyedStrings {
                self.localStrings.append(LocalString(key: key, languageCode: stringsFile.languageCode, string: string))
            }
        }
        
        super.init()
    }
    
    
    // MARK: - Key Creation
    
    func addNewKey() -> String {
        let baseKey = "newStringKey"
        var key = baseKey
        let string = "newLocalString"
        
        var keyIsUnique = false
        var uniqueKeyIdentifier = 0
        
        while !keyIsUnique {
            guard self.stringsFiles.first?.keyedStrings[key] != nil else {
                keyIsUnique = true
                break
            }
            
            uniqueKeyIdentifier += 1
            key = baseKey + "\(uniqueKeyIdentifier)"
        }
        
        for stringsFile in self.stringsFiles {
            stringsFile.keyedStrings[key] = string
            self.localStrings.append(LocalString(key: key, languageCode: stringsFile.languageCode, string: string))
        }
        
        return key
    }
    
    
    // MARK: - Checking Keys
    
    func containsKey(_ key: String) -> Bool {
        return self.stringsFiles.first?.keyedStrings.keys.contains(key) ?? false
    }
    
    
    // MARK: - Updating
    
    func updateKey(_ key: String, to newKey: String) {
        guard key != newKey else { return }
        
        for stringsFile in self.stringsFiles {
            stringsFile.keyedStrings[newKey] = stringsFile.keyedStrings[key]
            stringsFile.keyedStrings[key] = nil
        }
        
        for localString in self.localStrings where localString.key == key {
            localString.key = newKey
        }
    }
    
    func updateString(_ string: String, withKey key: String, forLanguageCode languageCode: String) {
        for stringsFile in self.stringsFiles where stringsFile.languageCode == languageCode {
            stringsFile.keyedStrings[key] = string
        }
        
        for localString in self.localStrings where localString.key == key && localString.languageCode == languageCode {
            localString.string = string
        }
    }
    
    
    // MARK: - Adding a language
    
    func addLanguage(withLanguageCode languageCode: String) throws {
        let languageDirectory = containingDirectory.appendingPathComponent(languageCode).appendingPathExtension("lproj")
        let newStringsFileURL = languageDirectory.appendingPathComponent(self.fileName)
        let newStringsFile = try StringsFile(url: newStringsFileURL, createNew: true)
        self.stringsFiles.append(newStringsFile)
        
        guard let keys = self.stringsFiles.first?.keyedStrings.keys else { return }
        
        for key in Array(keys) {
            self.localStrings.append(LocalString(key: key, languageCode: languageCode, string: ""))
        }
    }
    
    
    // MARK: - Saving
    
    func save(swiftFileURL: URL? = nil) {
        for stringsFile in self.stringsFiles {
            try? stringsFile.save()
        }
        
        guard let url = swiftFileURL else { return }
        
        var swiftFileContents = "import Foundation\n\nclass Localizable {\n\t\n\t// MARK: - String Keys\n\t\n"
        
        var usedKeys = [String]()
        
        for localString in self.localStrings where !usedKeys.contains(localString.key) && localString.key.isValidSwiftIdentifier() {
            usedKeys.append(localString.key)
            
            swiftFileContents += "\tstatic var \(localString.key): String { return NSLocalizedString(\"\(localString.key)\", comment: \"\") }\n"
        }
        
        swiftFileContents += "\t\n}\n"
        
        try! swiftFileContents.write(to: url, atomically: true, encoding: .utf8)
    }
    
}


fileprivate extension String {
    
    func isValidSwiftIdentifier() -> Bool {
        guard String(describing: self.characters.first).rangeOfCharacter(from: CharacterSet.decimalDigits) == nil else { return false }
        
        guard self.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) == nil else { return false }
        
        guard self.rangeOfCharacter(from: CharacterSet.symbols) == nil else { return false }
        
        guard self.rangeOfCharacter(from: CharacterSet.illegalCharacters) == nil else { return false }
        
        guard self.rangeOfCharacter(from: CharacterSet.controlCharacters) == nil else { return false }
        
        guard self.rangeOfCharacter(from: CharacterSet.nonBaseCharacters) == nil else { return false }
        
        guard self.rangeOfCharacter(from: CharacterSet.punctuationCharacters) == nil else { return false }
        
        guard self.rangeOfCharacter(from: CharacterSet.punctuationCharacters) == nil else { return false }
        
        return true
    }
    
}
