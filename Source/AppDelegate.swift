//
//  AppDelegate.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-03-25.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

var NSAppDelegate: AppDelegate {
    return NSApp.delegate as! AppDelegate
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    var mainWindowControllers = [UUID: MainWindowController]()
    
    
    // MARK: - NSApplicationDelegate Protocol
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        guard let url = URL(string: "file://" + filename) else { return false }
        
        self.open(url)
        
        return true
    }
    
    
    // MARK: - Methods
    
    func remove(_ windowController: MainWindowController) {
        guard let id = windowController.id else { return }
        self.mainWindowControllers[id] = nil
    }
    
    
    // MARK: - Menu Actions
    
    // MARK: - Opening
    
    func openDocument(_ sender: Any?) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["strings"]
        
        openPanel.begin(completionHandler: { result in
            guard result == NSFileHandlingPanelOKButton else { return }
            self.open(openPanel.urls[0])
        })
    }
    
    func open(_ url: URL) {
        let fileName = url.lastPathComponent
        let enclosingFolder = url.deletingLastPathComponent()
        let superEnclosingFolder = enclosingFolder.deletingLastPathComponent()
        
        self.openStrings(url, inDirectory: superEnclosingFolder, withFileName: fileName)
    }
    
    func openStrings(_ stringsFileURL: URL, inDirectory directoryURL: URL, withFileName fileName: String) {
        var alertMessage: String?
        
        do {
            self.newWindow(with: try Localization(containingDirectory: directoryURL, fileName: fileName))
            RecentFilesManager.addStringsFileToRecent(stringsFileURL)
        } catch Localization.Error.filesNotFound {
            alertMessage = "Could not find any localizable strings files."
        } catch let error as NSError {
            alertMessage = error.localizedFailureReason
        }
        
        if let message = alertMessage {
            let alert = NSAlert()
            alert.messageText = message
            alert.runModal()
        }
    }
    
    func newWindow(with localization: Localization) {
        guard let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "MainWindowController") as? MainWindowController else { return }
        controller.id = UUID()
        controller.mainViewController?.localization = localization
        controller.showWindow(self)
        
        self.mainWindowControllers[controller.id!] = controller
        
        // Close any windows that don't have an id
        for window in NSApp.windows where (window.windowController as? MainWindowController)?.id == nil {
            DispatchQueue.main.async(execute: {
                window.close()
            })
        }
    }
    
}

