//
//  MetricWidgetDataRow.swift
//  GlassnodeAtAGlance
//
//  Created by Ondrej Barta on 25.11.23.
//

import Foundation
import SwiftUI

struct MetricWidgetDataRow : View {
    var label: String
    var value: Double
    var body: some View {
        HStack {
            Text(label)
                .opacity(0.5)
                .fontWeight(.medium)
                .font(.footnote)
            Spacer()
            Text(formatNumber(value: value))
                .opacity(0.5)
                .fontWeight(.medium)
                .font(.footnote)
        }
    }
}
