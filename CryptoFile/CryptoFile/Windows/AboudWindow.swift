//
//  AboudWindow.swift
//  CryptoFile
//
//  Created by hanwe lee on 2021/02/04.
//

import Cocoa

class AboudWindow: NSWindowController {
    
    //MARK: outlet
    @IBOutlet weak var versionLabel: NSTextField!
    
    //MARK: property
    
    //MARK: lifeCycle
    
    override func windowDidLoad() {
        super.windowDidLoad()
        initUI()
    }
    
    //MARK: func
    
    func initUI() {
        self.versionLabel.stringValue = "version : " + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")
    }
    
    //MARK: action


    
}
