//
//  LocalString.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-04-16.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

class LocalString: NSObject {
    
    // MARK: - Properties
    
    var key: String
    var languageCode: String
    var string: String
    var comment: String?
    
    
    // MARK: - Init
    
    init(key: String, languageCode: String, string: String, comment: String? = nil) {
        self.key = key
        self.languageCode = languageCode
        self.string = string
        self.comment = comment
    }
    
}
