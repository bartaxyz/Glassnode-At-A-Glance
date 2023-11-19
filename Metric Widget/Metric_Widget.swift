//
//  Metric_Widget.swift
//  Metric Widget
//
//  Created by Ondrej Barta on 17.11.23.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), family: context.family)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, family: context.family)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, family: context.family)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let family: WidgetFamily
}

struct ChartPreset {
    var dataPoints: [ProfitDataPoint]
    var minValue: Int
    var maxValue: Int
    var firstTimestamp: Int
    var lastTimestamp: Int
    var timeSpan: Int
}

private func chartLine(in geometry: GeometryProxy, chartPreset: ChartPreset) -> Path {
    var path = Path()
    
    let xScale = geometry.size.width / CGFloat(chartPreset.timeSpan)
    let yScale = geometry.size.height / CGFloat(chartPreset.maxValue - chartPreset.minValue)

    for (index, dataPoint) in chartPreset.dataPoints.enumerated() {
        let xPosition = CGFloat(dataPoint.t - chartPreset.firstTimestamp) * xScale
        let yPosition = geometry.size.height - CGFloat(dataPoint.v - chartPreset.minValue) * yScale
        
        if index == 0 {
            path.move(to: CGPoint(x: xPosition, y: yPosition))
        } else {
            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
        }
    }
    

    return path
}
func chartFill(in geometry: GeometryProxy, chartPreset: ChartPreset) -> Path {
    var path = chartLine(in: geometry, chartPreset: chartPreset)
    
    // Extend the path to the bottom right corner
    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
    // Extend the path to the bottom left corner
    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))

    // Close the path
    path.closeSubpath()
    return path
}

struct LineChartView: View {
    var dataPoints: [ProfitDataPoint]

    var body: some View {
        GeometryReader { geometry in
            var minValue: Int { dataPoints.map { $0.v }.min() ?? 0 }
            var maxValue: Int { dataPoints.map { $0.v }.max() ?? 0 }
            var firstTimestamp: Int { dataPoints.map { $0.t }.min() ?? 0 }
            var lastTimestamp: Int { dataPoints.map { $0.t }.max() ?? 0 }
            var timeSpan: Int { (lastTimestamp - firstTimestamp) }
            let chartPreset = ChartPreset(
                dataPoints: dataPoints,
                minValue: minValue,
                maxValue: maxValue,
                firstTimestamp: firstTimestamp,
                lastTimestamp: lastTimestamp,
                timeSpan: timeSpan
            )
            
            let linePath = chartLine(in: geometry, chartPreset: chartPreset)
            let fillPath = chartFill(in: geometry, chartPreset: chartPreset)
            
            let btcColor = Color.init(red: 247/255, green: 147/255, blue: 26/255, opacity: 1)
            let btcColorGradientStart = Color.init(red: 247/255, green: 147/255, blue: 26/255, opacity: 0.25)
            let btcColorGradientEnd = Color.init(red: 247/255, green: 147/255, blue: 26/255, opacity: 0)
            
            linePath.stroke(
                Color.init(red: 247/255, green: 147/255, blue: 26/255, opacity: 1),
                style: StrokeStyle(lineWidth: 2)
            )
            fillPath.fill(
                LinearGradient(
                    gradient: Gradient(colors: [btcColorGradientStart, btcColorGradientEnd]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

struct MetricWidgetTitle : View {
    var body: some View {
        Text("BTC: Number of Addresses in Profit")
            .opacity(0.5)
            .fontWeight(.medium)
    }
}
struct MetricWidgetCurrentValue : View {
    var currentValue: Int
    var body : some View {
        Text("\(currentValue)")
            .fontWeight(.medium)
            .font(.largeTitle)
    }
}
struct MetricWidgetDataRow : View {
    var label: String
    var value: String
    var body: some View {
        HStack {
            Text(label)
                .opacity(0.5)
                .fontWeight(.medium)
                .font(.callout)
            Spacer()
            Text(value)
                .opacity(0.5)
                .fontWeight(.medium)
                .font(.callout)
        }
    }
}

struct StructuredData {
    var dataPoints: [ProfitDataPoint]
    var currentValue: Int
    var minValue: Int
    var maxValue: Int
}

struct Metric_WidgetEntryView : View {
    var entry: Provider.Entry
    let profitData: ProfitData? = loadProfitData()
    @State var apiKey = KeychainStore.shared.getApiKey()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let dataPoints = profitData {
                let currentValue = dataPoints[dataPoints.count - 1]
                var minValue: Int { dataPoints.map { $0.v }.min() ?? 0 }
                var maxValue: Int { dataPoints.map { $0.v }.max() ?? 0 }
                
                var structuredData = StructuredData(
                    dataPoints: dataPoints,
                    currentValue: currentValue.v,
                    minValue: minValue,
                    maxValue: maxValue
                )
                
                switch entry.family {
                case .systemSmall:
                    smallLayoutView(data: structuredData)
                case .systemMedium:
                    mediumLayoutView(data: structuredData)
                case .systemLarge:
                    largeLayoutView(data: structuredData)
                default:
                    Text("")
                }
            } else {
                Text("No data available")
                    .padding()
            }
            /* if let apiKey = apiKey, !apiKey.isEmpty {
                VStack {
                    Text("Time:")
                    Text(entry.date, style: .time)
                    
                    Text("Favorite Emojissssss:")
                    Text(entry.configuration.favoriteEmoji)
                    
                    Link(destination: URL(string: "glassnode-at-a-glance://addapikey")!) {
                        Text("Tap to add API Key")
                    }
                    
                    Text("\(apiKey)")
                }
            } else {
                Link(destination: URL(string: "glassnode-at-a-glance://addapikey")!) {
                    Text("Tap to add API Key")
                }
            } */
        }
        .onAppear {
            // print("reading api key from keychain")
            apiKey = KeychainStore.shared.getApiKey()
            // print("apiKey is ", apiKey ?? "nil")
            
            print(profitData)
        }
    }
    
    
    private func smallLayoutView(data: StructuredData) -> some View {
        VStack(alignment: .leading) {
            MetricWidgetTitle()
            LineChartView(dataPoints: data.dataPoints)
            MetricWidgetCurrentValue(currentValue: data.currentValue)
        }
    }

    private func mediumLayoutView(data: StructuredData) -> some View {
        VStack(alignment: .leading) {
            MetricWidgetTitle()
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    MetricWidgetCurrentValue(currentValue: data.currentValue)
                    Spacer()
                    MetricWidgetDataRow(label: "High", value: "\(data.maxValue)")
                    MetricWidgetDataRow(label: "Low", value: "\(data.minValue)")
                }
                LineChartView(dataPoints: data.dataPoints)
                    .padding(8)
            }
        }
    }

    private func largeLayoutView(data: StructuredData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            MetricWidgetTitle()
            Divider()
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    MetricWidgetDataRow(label: "High", value: "\(data.maxValue)")
                    MetricWidgetDataRow(label: "Low", value: "\(data.minValue)")
                }
                Divider()
                HStack {
                    Spacer()
                    MetricWidgetCurrentValue(currentValue: data.currentValue)
                }
                LineChartView(dataPoints: data.dataPoints)
                    .padding(8)
            }
        }
    }
}

struct Metric_Widget: Widget {
    let kind: String = "Metric_Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Metric_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
