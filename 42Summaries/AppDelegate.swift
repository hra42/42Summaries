//
//  AppDelegate.swift
//  42Summaries
//
//  Created by Henry Rausch on 05.10.24.
//
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var aboutWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupAboutMenuItem()
    }
    
    func setupAboutMenuItem() {
        
        // Remove existing About menu item if it exists
        if let appMenu = NSApp.mainMenu?.items.first?.submenu {
            if let existingAboutItem = appMenu.items.first(where: { $0.title == "About 42Summaries" }) {
                appMenu.removeItem(existingAboutItem)
            }
        }
        
        // Create the About menu item
        let aboutMenuItem = NSMenuItem(title: "About 42Summaries", action: #selector(showAboutView), keyEquivalent: "")
        aboutMenuItem.target = self
        
        // Insert the About menu item
        NSApp.mainMenu?.items.first?.submenu?.insertItem(aboutMenuItem, at: 0)
        NSApp.mainMenu?.items.first?.submenu?.insertItem(NSMenuItem.separator(), at: 1)
        
    }
    
    @objc func showAboutView() {
        if aboutWindow == nil {
            let aboutView = AboutView()
            let hostingController = NSHostingController(rootView: aboutView)
            
            aboutWindow = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 400, height: 500),
                                   styleMask: [.titled, .closable, .miniaturizable],
                                   backing: .buffered,
                                   defer: false)
            aboutWindow?.title = "About 42Summaries"
            aboutWindow?.contentViewController = hostingController
        }
        
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
