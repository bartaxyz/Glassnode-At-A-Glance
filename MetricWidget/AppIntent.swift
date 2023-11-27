//
//  AppIntent.swift
//  Metric Widget
//
//  Created by Ondrej Barta on 17.11.23.
//

import WidgetKit
import AppIntents
import GlassnodeSwift

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(
        title: "Asset",
        optionsProvider: MetricAssetOptionsProvider()
    )
    var metricAsset: MetricAssetAppEntity?
    
    private struct MetricAssetOptionsProvider: DynamicOptionsProvider {
        func results() async throws -> [MetricAssetAppEntity] {
            return try await MetricAssetEntityQuery.getAllEntities() ?? []
        }
        func defaultResult() async throws -> MetricAssetAppEntity? {
            return try await MetricAssetEntityQuery.getAllEntities()?.first
        }
    }
    
    @Parameter(
        title: "Metric",
        optionsProvider: MetricOptionsProvider()
    )
    var metric: MetricAppEntity?

    private struct MetricOptionsProvider: DynamicOptionsProvider {
        @IntentParameterDependency<ConfigurationAppIntent>(
            \.$metricAsset
        )
        var intent

        func results() async throws -> [MetricAppEntity] {
            return try await MetricEntityQuery.getAllEntities()?.filter { entity in
                entity.metricAssets.contains { asset in
                    asset == intent?.metricAsset.symbol
                }
            } ?? []
        }
        
        func defaultResult() async throws -> MetricAppEntity? {
            return try await MetricEntityQuery.getAllEntities()?.filter { entity in
                entity.metricAssets.contains { asset in
                    asset == intent?.metricAsset.symbol
                }
            }.first
        }
    }
}
