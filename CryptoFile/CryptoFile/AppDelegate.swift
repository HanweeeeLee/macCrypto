//
//  AppDelegate.swift
//  CryptoFile
//
//  Created by hanwe on 2021/01/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let aboutWindowController: AboudWindow = AboudWindow.init(windowNibName: "AboudWindow")


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func clickedAboutItem(_ sender: Any) {
        self.aboutWindowController.showWindow(nil)
    }
    
}

