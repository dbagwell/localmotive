//
//  LocalizationListViewController.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-04-06.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

class LocalizationListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSTextViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var localizationListView: NSTableView!
    @IBOutlet var commentTextView: NSTextView!
    
    
    // MARK: - Properties
    
    var localization: Localization?
    
    var currentStringKey = "" {
        didSet {
            self.checkSearchTerm()
            self.localizationListView.reloadData()
            
            if self.currentStringKey != "" {
                self.comment = self.localization?.stringsFiles[0].keyedComments[self.currentStringKey] ?? ""
                self.commentTextView.string = self.comment
                self.commentTextView.isEditable = true
            } else {
                self.comment = ""
                self.commentTextView.string = ""
                self.commentTextView.isEditable = false
            }
        }
    }
    
    var comment = "" {
        didSet {
            self.localization?.updateComment(self.comment, forKey: self.currentStringKey)
        }
    }
    
    var searchTerm = "" {
        didSet {
            self.checkSearchTerm()
        }
    }
    
    var currentLocalizationContainsSearchTerm = true {
        didSet {
            self.localizationListView.reloadData()
        }
    }
    
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localizationListView.delegate = self
        self.localizationListView.dataSource = self
        
        self.localizationListView.doubleAction = #selector(self.editSelectedRow)
        
        self.commentTextView.delegate = self
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        self.updateRowHeights()
    }
    
    
    // MARK: - Methods
    
    func checkSearchTerm() {
        guard let localization = self.localization, self.searchTerm != "" else {
            self.currentLocalizationContainsSearchTerm = true
            return
        }
        
        guard !self.currentStringKey.lowercased().contains(self.searchTerm.lowercased()) else {
            self.currentLocalizationContainsSearchTerm = true
            return
        }
        
        for stringsFile in localization.stringsFiles {
            if let string = stringsFile.keyedStrings[self.currentStringKey], string.lowercased().contains(self.searchTerm.lowercased()) {
                self.currentLocalizationContainsSearchTerm = true
                return
            }
        }
        
        self.currentLocalizationContainsSearchTerm = false
    }
    
    @objc func editSelectedRow() {
        let selectedRow = self.localizationListView.selectedRow
        guard (0..<self.localizationListView.numberOfRows).contains(selectedRow) else { return }
        (self.localizationListView.view(atColumn: 1, row: selectedRow, makeIfNecessary: false) as? NSTextField)?.becomeFirstResponder()
    }
    
    func updateRowHeights() {
        let allIndex = IndexSet(integersIn:0..<self.localizationListView.numberOfRows)
        self.localizationListView.noteHeightOfRows(withIndexesChanged: allIndex)
    }
    
    
    // MARK: - NSTableViewDataSource Protocol
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.currentLocalizationContainsSearchTerm ? self.localization?.stringsFiles.count ?? 0 : 0
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let stringsFile = self.localization?.stringsFiles[row] else { return 0 }

        let label = NSTextField()
        label.stringValue = stringsFile.keyedStrings[self.currentStringKey] ?? ""
        label.lineBreakMode = .byWordWrapping

        return label.sizeThatFits(NSSize(width: tableView.tableColumns[1].width, height: CGFloat.greatestFiniteMagnitude)).height
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let stringsFile = self.localization?.stringsFiles[row] else { return nil }
        
        let value = tableColumn?.title == "Language" ? stringsFile.languageCode : stringsFile.keyedStrings[self.currentStringKey] ?? ""
        
        let label = NSTextField()
        label.isBordered = false
        label.drawsBackground = false
        label.stringValue = value
        label.lineBreakMode = .byWordWrapping
        
        if tableColumn?.title == "Language" {
            label.isEditable = false
        } else {
            label.delegate = self
        }
        
        return label
    }
    
    
    // MARK: - NSControlTextEditingDelegate Protocol
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let selectedRow = self.localizationListView.selectedRow
        guard (0..<(self.localization?.stringsFiles.count ?? 0)).contains(selectedRow) else { return true }
        let languageCode = self.localization?.stringsFiles[selectedRow].languageCode ?? ""
        var string = fieldEditor.string
        string = string.replacingOccurrences(of: "\n", with: "\\n")
        string = string.replacingOccurrences(of: "\t", with: "\\t")
        fieldEditor.string = string
        self.localization?.updateString(string, withKey: self.currentStringKey, forLanguageCode: languageCode)
        self.updateRowHeights()
        
        return true
    }
    
    
    // MARK: - NSTextDelegate Protocol
    
    func textDidChange(_ notification: Notification) {
        self.comment = self.commentTextView.string
    }
    
}
