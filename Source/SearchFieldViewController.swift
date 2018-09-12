//
//  SearchFieldViewController.swift
//  Localmotive
//
//  Created by David Bagwell on 2017-04-10.
//  Copyright © 2017 GB Internet Solutions. All rights reserved.
//

import Cocoa

protocol SearchFieldViewControllerDelegate: class {
    func searchFieldViewControllerDidChangeSearchText(to text: String)
}


class SearchFieldViewController: NSViewController, NSSearchFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var searchField: NSSearchField!
    
    
    // MARK: - Protperties
    
    weak var delegate: SearchFieldViewControllerDelegate?
    
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchField.delegate = self
    }
    
    
    // MARK: - Methods
    
    func setSearchString(to string: String) {
        self.searchField.stringValue = string
        self.delegate?.searchFieldViewControllerDidChangeSearchText(to: self.searchField.stringValue)
    }
    
    
    // MARK: - NSSearchFieldDelegate Procotol
    
    func controlTextDidChange(_ obj: Notification) {
        self.delegate?.searchFieldViewControllerDidChangeSearchText(to: self.searchField.stringValue)
    }
    
}
