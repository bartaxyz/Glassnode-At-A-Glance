//
//  LineChartView.swift
//  GlassnodeAtAGlance
//
//  Created by Ondrej Barta on 25.11.23.
//

import Foundation
import SwiftUI
import Charts
import GlassnodeSwift

struct LineChartView: View {
    var dataPoints: [MetricDataDatum]
    var isXAxisVisible = true
    
    var body: some View {
        var minValue: Double { dataPoints.map { $0.v }.min() ?? 0 }
        var maxValue: Double { dataPoints.map { $0.v }.max() ?? 0 }
        
        let firstItem = dataPoints[0]
        let lastItem = dataPoints[dataPoints.count - 1]
        let midPointItem = dataPoints[abs(dataPoints.count / 2)]
        
        let btcColor = Color.init(red: 247/255, green: 147/255, blue: 26/255)
        
        let adjustedDataPoints = dataPoints.map { ProfitDataPoint(t: $0.t, v: $0.v - minValue) }
        
        Chart(adjustedDataPoints) {
            AreaMark(
                x: .value("Time", $0.t),
                y: .value("Value", $0.v)
            )
            .foregroundStyle(
                LinearGradient(gradient: Gradient(colors: [btcColor.opacity(0.4), btcColor.opacity(0)]),
                               startPoint: .top,
                               endPoint: .bottom)
            )
            LineMark(
                x: .value("Time", $0.t),
                y: .value("Value", $0.v)
            )
            .foregroundStyle(btcColor)
            
        }
        .chartYScale(domain: [0, maxValue - minValue])
        .chartYAxis(.hidden)
        .chartXScale(domain: [dataPoints[0].t, dataPoints[dataPoints.count - 1].t])
        .chartXAxis {
            AxisMarks(values: [firstItem.t, lastItem.t, midPointItem.t]) { value in
                AxisGridLine()
                if isXAxisVisible {
                    AxisValueLabel(formatDate(timestamp: value.as(Int.self)!))
                }
            }
        }
    }
    
    func formatDate(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}
