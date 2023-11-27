//
//  MetricWidgetCurrentValue.swift
//  GlassnodeAtAGlance
//
//  Created by Ondrej Barta on 25.11.23.
//

import Foundation
import SwiftUI

struct MetricWidgetCurrentValue : View {
    var currentValue: Double
    var body : some View {
        Text(formatNumber(value: currentValue))
            .fontWeight(.medium)
            .font(.largeTitle)
            .minimumScaleFactor(0.01)
    }
}
