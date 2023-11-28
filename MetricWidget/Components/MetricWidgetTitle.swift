//
//  MetricWidgetTitle.swift
//  GlassnodeAtAGlance
//
//  Created by Ondrej Barta on 25.11.23.
//

import Foundation
import SwiftUI

struct MetricWidgetTitle : View {
    var title: String?
    var assetSymbol: String?
    var body: some View {
        if let label = title, let asset = assetSymbol {
            Text(asset + ": " + label)
                .opacity(0.5)
                .fontWeight(.medium)
        } else {
            Text("-: -")
        }
    }
}
