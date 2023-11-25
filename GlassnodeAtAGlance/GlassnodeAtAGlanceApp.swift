//
//  GlassnodeAtAGlanceAppApp.swift
//  Glassnode At A Glance
//
//  Created by Ondrej Barta on 17.11.23.
//

import SwiftUI

struct GlassnodeAtAGlanceApp: App {
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
