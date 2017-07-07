//
//  String.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-07-07.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

extension String {

    func strictCaseInsensitiveCompare(_ otherString: String) -> ComparisonResult {
        let result = self.caseInsensitiveCompare(otherString)
        
        if result == .orderedSame {
            return self.compare(otherString)
        } else {
            return result
        }
    }
    
}
