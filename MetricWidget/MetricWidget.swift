//
//  MetricWidget.swift
//  Metric Widget
//
//  Created by Ondrej Barta on 17.11.23.
//

import WidgetKit
import SwiftUI
import Charts

func formatNumber(value: Int) -> String {
    let customFormatter = NumberFormatter()
    customFormatter.numberStyle = .decimal
    customFormatter.maximumFractionDigits = 2
    customFormatter.minimumFractionDigits = 0
    customFormatter.usesGroupingSeparator = true
    
    return customFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

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

struct LineChartView: View {
    var dataPoints: [ProfitDataPoint]
    var isXAxisVisible = true
    
    var body: some View {
        var minValue: Int { dataPoints.map { $0.v }.min() ?? 0 }
        var maxValue: Int { dataPoints.map { $0.v }.max() ?? 0 }
        
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
            .minimumScaleFactor(0.01)
    }
}
struct MetricWidgetDeltaValue : View {
    var firstValue: Int
    var lastValue: Int
    var body : some View {
        let deltaValue = lastValue - firstValue
        let deltaPercent = String(format: "%.2f", (100.0 / Double(firstValue)) * Double(deltaValue))
        let arrow = deltaValue > 0 ? "▲" : "▼"
        let symbol = deltaValue > 0 ? "+" : "-"
        let color = deltaValue > 0 ? Color.green : Color.red
        let backgroundColor = color.opacity(0.1)
        
        HStack {
            VStack {
                Text("\(arrow) \(symbol)\(deltaValue)")
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
struct MetricWidgetDataRow : View {
    var label: String
    var value: Int
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

struct StructuredData {
    var dataPoints: [ProfitDataPoint]
    var currentValue: Int
    var minValue: Int
    var maxValue: Int
    var firstValue: Int
    var lastValue: Int
}

struct MetricWidgetEntryView : View {
    var entry: Provider.Entry
    let profitData: ProfitData? = loadProfitData()
    @State var apiKey = KeychainStore.shared.getApiKey()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let dataPoints = profitData {
                let currentValue = dataPoints[dataPoints.count - 1]
                var minValue: Int { dataPoints.map { $0.v }.min() ?? 0 }
                var maxValue: Int { dataPoints.map { $0.v }.max() ?? 0 }
                
                let structuredData = StructuredData(
                    dataPoints: dataPoints,
                    currentValue: currentValue.v,
                    minValue: minValue,
                    maxValue: maxValue,
                    firstValue: dataPoints[0].v,
                    lastValue: dataPoints[dataPoints.count - 1].v
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
                    
                    Link(destination: URL(string: "GlassnodeAtAGlance://addapikey")!) {
                        Text("Tap to add API Key")
                    }
                    
                    Text("\(apiKey)")
                }
            } else {
                Link(destination: URL(string: "GlassnodeAtAGlance://addapikey")!) {
                    Text("Tap to add API Key")
                }
            } */
        }
        .onAppear {
            // print("reading api key from keychain")
            apiKey = KeychainStore.shared.getApiKey()
            // print("apiKey is ", apiKey ?? "nil")
            
            print(profitData as Any)
        }
    }
    
    
    private func smallLayoutView(data: StructuredData) -> some View {
        VStack(alignment: .leading) {
            MetricWidgetTitle()
            LineChartView(dataPoints: data.dataPoints, isXAxisVisible: false)
            MetricWidgetCurrentValue(currentValue: data.currentValue)
        }
    }

    private func mediumLayoutView(data: StructuredData) -> some View {
        VStack(alignment: .leading) {
            MetricWidgetTitle()
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    MetricWidgetCurrentValue(currentValue: data.currentValue)
                    MetricWidgetDeltaValue(firstValue: data.firstValue, lastValue: data.lastValue)
                    Spacer()
                    MetricWidgetDataRow(label: "High", value: data.maxValue)
                    MetricWidgetDataRow(label: "Low", value: data.minValue)
                }
                LineChartView(dataPoints: data.dataPoints)
            }
        }
    }

    private func largeLayoutView(data: StructuredData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            MetricWidgetTitle()
            VStack(spacing: 16) {
                HStack {
                    MetricWidgetCurrentValue(currentValue: data.currentValue)
                    Spacer()
                    MetricWidgetDeltaValue(firstValue: data.firstValue, lastValue: data.lastValue)
                }
                LineChartView(dataPoints: data.dataPoints)
                VStack(spacing: 8) {
                    MetricWidgetDataRow(label: "High", value: data.maxValue)
                    MetricWidgetDataRow(label: "Low", value: data.minValue)
                }
            }
        }
    }
}

struct MetricWidget: Widget {
    let kind: String = "MetricWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MetricWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
