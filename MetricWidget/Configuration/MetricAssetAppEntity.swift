//
//  MetricAssetAppEntity.swift
//  GlassnodeAtAGlance
//
//  Created by Ondrej Barta on 26.11.23.
//

import WidgetKit
import AppIntents
import GlassnodeSwift

struct MetricAssetAppEntity: AppEntity {
    typealias DefaultQuery = MetricAssetEntityQuery
    static var defaultQuery = MetricAssetEntityQuery()
    
    var id: String
    var name: String
    var symbol: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "MetricAssetAppEntity"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(symbol) - \(name)")
    }
}

final class MetricAssetEntityQuery: EntityQuery {
    static var allEntities: [MetricAssetAppEntity]?;
    
    required init() {
        Task {
            do {
                try await MetricAssetEntityQuery.fetchAndCacheAllEntities()
            }
        }
    }
    
    static func fetchAndCacheAllEntities() async throws {
        let metricAssets = try await GlassnodeSwift.fetchAllMetricAssets()
        MetricAssetEntityQuery.allEntities = metricAssets.data
            .map {
                MetricAssetAppEntity(
                    id: "\($0.id)",
                    name: $0.attributes.name,
                    symbol: $0.attributes.symbol
                )
            }
            .sorted { $0.symbol < $1.symbol }
    }
    static func getAllEntities() async throws -> [MetricAssetAppEntity]? {
        if MetricAssetEntityQuery.allEntities != nil {
            return MetricAssetEntityQuery.allEntities
        }
        try await fetchAndCacheAllEntities()
        return MetricAssetEntityQuery.allEntities
    }
    
    func entities(for identifiers: [MetricAssetAppEntity.ID]) async throws -> [MetricAssetAppEntity] {
        try await MetricAssetEntityQuery.getAllEntities()?.filter { identifiers.contains($0.id) } ?? []
    }
    
    func suggestedEntities() async throws -> [MetricAssetAppEntity] {
        try await MetricAssetEntityQuery.getAllEntities() ?? []
    }
    
    func defaultResult() async throws -> MetricAssetAppEntity? {
        try await MetricAssetEntityQuery.getAllEntities()?.first
    }
}
