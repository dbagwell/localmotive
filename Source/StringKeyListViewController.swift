//
//  StringKeyListViewController.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-03-26.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

protocol StringKeyListViewControllerDelegate: class {
    func stringKeyListViewControllerDidSelectStringKey(_ stringKey: String)
}

class StringKeyListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var stringKeyListView: NSTableView!
    
    
    // MARK: - Properties
    
    weak var delegate: StringKeyListViewControllerDelegate?
    
    var localization: Localization? {
        didSet {
            self.updateFilteredStringKeys()
        }
    }
    
    var filteredLocalStrings = [LocalString]() {
        didSet {
            self.stringKeyListView.reloadData()
            
            if let index = self.filteredLocalStrings.index(where: { $0.key == self.currentStringKey }) {
                self.stringKeyListView.selectRowIndexes([index], byExtendingSelection: false)
            }
        }
    }
    
    var searchTerm = "" {
        didSet {
            self.updateFilteredStringKeys()
        }
    }
    
    var currentStringKey = "" {
        didSet {
            if let index = self.filteredLocalStrings.index(where: { $0.key == self.currentStringKey }) {
                self.stringKeyListView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
                self.stringKeyListView.scrollRowToVisible(index)
            }
            
            self.delegate?.stringKeyListViewControllerDidSelectStringKey(self.currentStringKey)
        }
    }
    
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stringKeyListView.delegate = self
        self.stringKeyListView.dataSource = self
        
        self.stringKeyListView.doubleAction = #selector(self.editSelectedRow)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.updateFilteredStringKeys()
    }
    
    
    // MARK: - Updating Keys
    
    func updateFilteredStringKeys() {
        guard let localization = self.localization else { return }
        
        var filteredLocalStrings = [LocalString]()
        for localString in localization.localStrings where !filteredLocalStrings.contains(where: { $0.key == localString.key })
            && (self.searchTerm == "" || localString.key.lowercased().contains(self.searchTerm.lowercased()) || localString.string.lowercased().contains(self.searchTerm.lowercased())) {
            filteredLocalStrings.append(localString)
        }
        
        self.filteredLocalStrings = filteredLocalStrings
    }
    
    func editSelectedRow() {
        let selectedRow = self.stringKeyListView.selectedRow
        guard (0..<self.stringKeyListView.numberOfRows).contains(selectedRow) else { return }
        (self.stringKeyListView.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? NSTextField)?.becomeFirstResponder()
    }
    
    
    // MARK: - Deleting
    
    func delete(_ sender: Any?) {
        self.localization?.deleteKey(self.currentStringKey)
        self.currentStringKey = ""
        self.updateFilteredStringKeys()
    }
    
    
    // MARK: - NSTableViewDataSource Protocol
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.filteredLocalStrings.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let label = NSTextField()
        label.isBordered = false
        label.drawsBackground = false
        label.stringValue = self.filteredLocalStrings[row].key
        label.delegate = self
        label.lineBreakMode = .byTruncatingTail
        return label
    }
    
    
    // MARK: - NSTableViewDelegate Protocol
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = self.stringKeyListView.selectedRow
        guard (0..<self.filteredLocalStrings.count).contains(selectedRow) else { return }
        self.currentStringKey = self.filteredLocalStrings[selectedRow].key
    }
    
    
    // MARK: - NSControlTextEditingDelegate Protocol
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let newKey = fieldEditor.string ?? ""
        
        guard newKey != "" else {
            self.delete(nil)
            return true
        }
        
        guard newKey == self.currentStringKey || !(self.localization?.containsKey(newKey) ?? false) else {
            let alert = NSAlert()
            alert.messageText = "The key \"\(newKey)\" already exists."
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
            return false
        }
        
        self.localization?.updateKey(self.currentStringKey, to: newKey)
        self.currentStringKey = newKey
        
        return true
    }
    
}

