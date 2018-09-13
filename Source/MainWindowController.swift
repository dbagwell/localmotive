//
//  MainWindowController.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-03-27.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    // MARK: - Properties
    
    var id: UUID?
    
    var mainViewController: MainViewController? {
        return self.contentViewController as? MainViewController
    }
    
    
    // MARK: - Life Cycle

    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.delegate = self
        
        DispatchQueue.main.async {
            self.window?.makeFirstResponder(nil)
            let fileName = self.mainViewController?.localization?.fileName ?? ""
            let path = self.mainViewController?.localization?.containingDirectory.path ?? ""
            self.window?.title = fileName + " - " + path
        }
    }
    
    
    // MARK: - NSWindowDelegate Protocol
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // WARN: Check if saving needed
        
        NSAppDelegate.remove(self)
        
        return true
    }

}
