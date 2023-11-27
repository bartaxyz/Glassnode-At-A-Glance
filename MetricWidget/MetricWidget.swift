//
//  MetricWidget.swift
//  Metric Widget
//
//  Created by Ondrej Barta on 17.11.23.
//

import WidgetKit
import SwiftUI
import Charts
import GlassnodeSwift

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), family: context.family, metricData: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        var metricData: MetricData? = await fetchMetricData(configuration: configuration)
    
        return SimpleEntry(date: Date(), configuration: configuration, family: context.family, metricData: metricData)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        var metricData: MetricData? = await fetchMetricData(configuration: configuration)

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 1 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, family: context.family, metricData: metricData)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
    
    func fetchMetricData(configuration: ConfigurationAppIntent) async -> MetricData? {
        var metricData: MetricData? = nil
        if let metricPath = configuration.metric?.metricPath, let assetSymbol = configuration.metricAsset?.symbol {
            do {
                metricData = try await GlassnodeSwift.APIService.fetchMetricData(
                    metricPath: metricPath,
                    assetSymbol: assetSymbol
                )
            } catch {
                print("Error fetching metric data: \(error)")
            }
        }
        return metricData
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let family: WidgetFamily
    let metricData: MetricData?
}

struct ChartPreset {
    var dataPoints: [ProfitDataPoint]
    var minValue: Int
    var maxValue: Int
    var firstTimestamp: Int
    var lastTimestamp: Int
    var timeSpan: Int
}

struct StructuredData {
    var name: String?
    var shortName: String?
    var assetSymbol: String?
    var dataPoints: [MetricDataDatum]
    var currentValue: Double
    var minValue: Double
    var maxValue: Double
    var firstValue: Double
    var lastValue: Double
}

struct MetricWidgetDataView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            if let dataPoints = entry.metricData {
                if dataPoints.count < 1 {
                    Text("Not enough data points")
                } else {
                    let currentValue = dataPoints[dataPoints.count - 1]
                    var minValue: Double { dataPoints.map { $0.v }.min() ?? 0 }
                    var maxValue: Double { dataPoints.map { $0.v }.max() ?? 0 }
                    
                    let structuredData = StructuredData(
                        name: entry.configuration.metric?.name,
                        shortName: entry.configuration.metric?.shortName,
                        assetSymbol: entry.configuration.metricAsset?.symbol,
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
                }
            } else {
                Text("No data available")
                    .padding()
            }
        }
    }
    
    private func smallLayoutView(data: StructuredData) -> some View {
        VStack(alignment: .leading) {
            MetricWidgetTitle(title: data.name, assetSymbol: data.assetSymbol)
            LineChartView(dataPoints: data.dataPoints, isXAxisVisible: false)
            MetricWidgetCurrentValue(currentValue: data.currentValue)
        }
    }

    private func mediumLayoutView(data: StructuredData) -> some View {
        VStack(alignment: .leading) {
            MetricWidgetTitle(title: data.name, assetSymbol: data.assetSymbol)
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
            MetricWidgetTitle(title: data.shortName, assetSymbol: data.assetSymbol)
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

struct MetricWidgetEntryView : View {
    var entry: Provider.Entry
    @State var apiKey = KeychainStore.shared.getApiKey()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let apiKey = apiKey, !apiKey.isEmpty {
                if (entry.configuration.metric != nil), (entry.configuration.metricAsset != nil) {
                    MetricWidgetDataView(entry: entry)
                } else {
                    Text("Select asset & metric to display")
                }
            } else {
                Link(destination: URL(string: "glassnode-at-a-glance://addapikey")!) {
                    Text("Tap to add API Key")
                }
            }
        }
        .onAppear {
            apiKey = KeychainStore.shared.getApiKey()
            GlassnodeSwift.configuration.apiKey = apiKey
        }
    }
}

struct MetricWidget: Widget {
    let kind: String = "MetricWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            MetricWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
