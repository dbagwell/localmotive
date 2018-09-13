//
//  RecentFilesManager.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-06-30.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

class RecentFilesManager: NSObject {
    
    private static let keyPrefix = "Localmotive.RecentFilesManager."
    
    
    // MARK: - Recent Strings Files
    
    class func recentStringsFilesURLs() -> [URL] {
        return NSDocumentController.shared.recentDocumentURLs
    }
    
    class func addStringsFileToRecent(_ url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
    }
    
    
    // MARK: - Recent Swift Files
    
    private static let recentSwiftFileURLsKey = keyPrefix + "recentFileSwiftFileURLs"
    
    private static var recentSwiftFileURLs: [[String: String]] {
        get {
            return UserDefaults.standard.object(forKey: self.recentSwiftFileURLsKey) as? [[String : String]] ?? [[:]]
        }
        set {
            var newValue = newValue
            
            if newValue.count > 10 {
                newValue.removeFirst()
            }
            
            UserDefaults.standard.set(newValue, forKey: self.recentSwiftFileURLsKey)
        }
    }
    
    class func swiftFileUrl(for localization: Localization) -> URL? {
        let key = localization.containingDirectory.appendingPathExtension(localization.fileName).path
        
        if let index = self.recentSwiftFileURLs.index(where: { $0[key] != nil }), let urlString = self.recentSwiftFileURLs[index][key] {
            return URL(string: urlString)
        }
        
        return nil
    }
    
    class func addSwiftFileToRecent(_ swiftFileURL: URL, for localization: Localization) {
        let key = localization.containingDirectory.appendingPathExtension(localization.fileName).path
        
        if let index = self.recentSwiftFileURLs.index(where: { $0[key] != nil }) {
            self.recentSwiftFileURLs.remove(at: index)
        }
        
        self.recentSwiftFileURLs.append([key : swiftFileURL.absoluteString])
    }
    
}
