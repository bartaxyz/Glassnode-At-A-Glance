//
//  AppDelegate.swift
//  Glassnode At A Glance
//
//  Created by Ondrej Barta on 25.11.23.
//

import Foundation
import GlassnodeSwift
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var apiKeyWindowController: NSWindowController?
    var mainWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if GlassnodeSwift.configuration.apiKey == nil {
            // API key not set, show API key prompt window
            showAPIKeyPromptWindow()
        } else {
            // API key is set, show main app window
            showMainWindow()
        }
    }

    func showAPIKeyPromptWindow() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "APIKeyWindowController") as! NSWindowController
        apiKeyWindowController = windowController
        windowController.showWindow(self)
    }

    func showMainWindow() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "MainWindowController") as! NSWindowController
        mainWindowController = windowController
        windowController.showWindow(self)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Decide which window to show when clicking the app icon
            if GlassnodeSwift.configuration.apiKey == nil {
                apiKeyWindowController?.showWindow(self)
            } else {
                mainWindowController?.showWindow(self)
            }
        }
        return true
    }
}
