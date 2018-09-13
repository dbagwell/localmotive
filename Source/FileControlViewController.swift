//
//  FileControlViewController.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-05-26.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

class FileControlViewController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var pathSelector: NSPathControl!
    @IBOutlet var swiftFileNameTextField: NSTextField!
    
    
    // MARK: - Properties
    
    var localization: Localization? {
        didSet {
            if let localization = self.localization, let swiftFileURL = RecentFilesManager.swiftFileUrl(for: localization) {
                self.swiftFileNameTextField.stringValue = swiftFileURL.deletingPathExtension().lastPathComponent
                self.pathSelector.url = swiftFileURL.deletingLastPathComponent()
                
            } else {
                if let stringsFile = self.localization?.stringsFiles.first {
                    self.pathSelector.url = stringsFile.url.deletingLastPathComponent().deletingLastPathComponent()
                    self.swiftFileNameTextField.stringValue = stringsFile.url.deletingPathExtension().lastPathComponent
                    self.pathSelector.url = URL(string: "file://" + NSHomeDirectory())
                }
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func generateSwiftFileCheckboxClicked(_ sender: NSButton) {
        if sender.state.rawValue == 0 {
            self.pathSelector.isEnabled = false
            self.swiftFileNameTextField.isEnabled = false
        } else if sender.state.rawValue == 1 {
            self.pathSelector.isEnabled = true
            self.swiftFileNameTextField.isEnabled = true
        }
    }
    
    @IBAction func pathControlSelectedItem(_ sender: Any) {
        self.pathSelector.url = self.pathSelector.clickedPathComponentCell()?.url
    }
    
    // MARK: - Methods
    
    func swiftFileURL() -> URL? {
        return self.pathSelector.url?.appendingPathComponent(swiftFileNameTextField.stringValue).appendingPathExtension("swift")
    }
    
}
