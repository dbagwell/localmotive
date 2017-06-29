//
//  URL.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-04-06.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

extension URL {
    
    func appendingPathComponentIfExists(_ pathComponent: String) -> URL? {
        let url = self.appendingPathComponent(pathComponent)
        
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        } else {
            return nil
        }
    }
    
}
