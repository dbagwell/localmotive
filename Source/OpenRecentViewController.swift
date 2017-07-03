//
//  OpenRecentViewController.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-07-03.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

class OpenRecentViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var recentFilesListView: NSTableView!
    
    
    // MARK: - Properties
    
    var recentStringsFilesURLs = RecentFilesManager.recentStringsFilesURLs()
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recentFilesListView.dataSource = self
        self.recentFilesListView.delegate = self
    }
    
    
    // MARK: - NSTableViewDataSource Protocol
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.recentStringsFilesURLs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let url = self.recentStringsFilesURLs[row]
        let value = tableColumn?.title == "Recent Files" ? url.lastPathComponent : url.path
        
        let label = NSTextField()
        label.isBordered = false
        label.drawsBackground = false
        label.stringValue = value
        label.isEditable = false
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }
    
    
    // MARK: - NSTableViewDelegate Protocol
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = self.recentFilesListView.selectedRow
        guard (0..<self.recentStringsFilesURLs.count).contains(selectedRow) else { return }
        NSAppDelegate.open(self.recentStringsFilesURLs[selectedRow])
    }
    
}
