//
//  MainViewController.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-03-25.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, StringKeyListViewControllerDelegate, SearchFieldViewControllerDelegate {
    
    // MARK: - Properties
    
    var fileControlViewController: FileControlViewController!
    var searchFieldViewController: SearchFieldViewController!
    var stringKeyListViewController: StringKeyListViewController!
    var localizationListViewController: LocalizationListViewController!
    
    var localization: Localization? {
        didSet {
            self.fileControlViewController.localization = localization
            self.stringKeyListViewController.localization = localization
            self.localizationListViewController.localization = localization
        }
    }
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch (identifier, segue.destinationController) {
        case ("fileControlViewController", let controller as FileControlViewController):
            self.fileControlViewController = controller
            self.fileControlViewController.localization = self.localization
            
        case ("searchFieldViewController", let controller as SearchFieldViewController):
            self.searchFieldViewController = controller
            self.searchFieldViewController.delegate = self
            
        case ("stringKeyListViewController", let controller as StringKeyListViewController):
            self.stringKeyListViewController = controller
            self.stringKeyListViewController.localization = self.localization
            self.stringKeyListViewController.delegate = self
            
        case ("localizationListViewController", let controller as LocalizationListViewController):
            self.localizationListViewController = controller
            self.localizationListViewController.localization = self.localization
            
        default:
            break
        }
    }
    
    
    // MARK: - Saving
    
    func saveDocument(_ sender: Any?) {
        let swiftFileURL = self.fileControlViewController.swiftFileURL()
        self.localization?.save(swiftFileURL: swiftFileURL)
        
        if let localization = self.localization, let swiftFileURL = swiftFileURL {
            RecentFilesManager.addSwiftFileToRecent(swiftFileURL, for: localization)
        }
    }
    
    
    // MARK: - Updating
    
    func update() {
        try? self.localization?.update()
        self.stringKeyListViewController.updateFilteredStringKeys()
        self.localizationListViewController.currentStringKey = self.stringKeyListViewController.currentStringKey
    }
    
    
    // MARK: - Actions
    
    @IBAction func newKeyButtonPressed(_ sender: Any?) {
        let key = self.localization?.addNewKey() ?? ""
        self.searchFieldViewController.setSearchString(to: "")
        self.stringKeyListViewController.currentStringKey = key
    }
    
    @IBAction func newLanguageButtonPressed(_ sender: Any) {
        let textField = NSTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 24))
        
        let alert = NSAlert()
        alert.messageText = "Enter language code:"
        alert.accessoryView = textField
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = textField
        
        let result = alert.runModal()
        
        if result == NSApplication.ModalResponse.alertFirstButtonReturn {
            do {
                try self.localization?.addLanguage(withLanguageCode: textField.stringValue)
            } catch StringsFile.CreationError.fileExists {
                let alert = NSAlert()
                alert.messageText = "A strings file for the language \(textField.stringValue) already exists."
                alert.addButton(withTitle: "OK")
                alert.runModal()
            } catch {
                
            }
        }
    }
    
    
    // MARK: - StringKeyListViewControllerDelegate Protocol
    
    func stringKeyListViewControllerDidSelectStringKey(_ stringKey: String) {
        self.localizationListViewController.currentStringKey = stringKey
    }
    
    
    // MARK: - SearchFieldViewControllerDelegate Protocol
    
    func searchFieldViewControllerDidChangeSearchText(to text: String) {
        self.stringKeyListViewController.searchTerm = text
        self.localizationListViewController.searchTerm = text
    }
    
}

