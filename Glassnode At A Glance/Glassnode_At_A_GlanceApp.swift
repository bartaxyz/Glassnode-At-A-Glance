//
//  Glassnode_At_A_GlanceApp.swift
//  Glassnode At A Glance
//
//  Created by Ondrej Barta on 17.11.23.
//

import SwiftUI

@main
struct Glassnode_At_A_GlanceApp: App {
    var width = CGFloat(400)
    var height = CGFloat(160)
    
    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .frame(width: width, height: height)
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.automatic)
        .handlesExternalEvents(matching: Set(arrayLiteral: "addapikey"))
    }
}
