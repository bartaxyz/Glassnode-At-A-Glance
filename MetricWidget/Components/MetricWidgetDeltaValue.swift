//
//  MetricWidgetDeltaValue.swift
//  GlassnodeAtAGlance
//
//  Created by Ondrej Barta on 25.11.23.
//

import Foundation
import SwiftUI

struct MetricWidgetDeltaValue : View {
    var firstValue: Double
    var lastValue: Double
    var body : some View {
        let deltaValue = lastValue - firstValue
        let deltaPercent = String(format: "%.2f", (100.0 / firstValue) * Double(deltaValue))
        let arrow = deltaValue > 0 ? "▲" : "▼"
        let symbol = deltaValue > 0 ? "+" : ""
        let color = deltaValue > 0 ? Color.green : Color.red
        let backgroundColor = color.opacity(0.1)
        
        let formattedDeltaValue = formatNumber(value: deltaValue)
        
        HStack {
            VStack {
                Text("\(arrow) \(symbol)\(formattedDeltaValue)")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(color)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
            }.background(backgroundColor).cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
            
            Text("\(symbol)\(deltaPercent)%")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(color)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
        }
    }
}
