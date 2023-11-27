//
//  MetricAppEntity.swift
//  GlassnodeAtAGlance
//
//  Created by Ondrej Barta on 26.11.23.
//

import WidgetKit
import AppIntents
import GlassnodeSwift

struct MetricAppEntity: AppEntity {
    typealias DefaultQuery = MetricEntityQuery
    static var defaultQuery = MetricEntityQuery()
    
    var id: String
    var name: String
    var shortName: String?
    var metricAssets: [String]
    var metricPath: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "MetricAppEntity"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

final class MetricEntityQuery: EntityQuery {
    static var allEntities: [MetricAppEntity]?;
    
    required init() {
        Task {
            do {
                try await MetricEntityQuery.fetchAndCacheAllEntities()
            }
        }
    }
    
    static func fetchAndCacheAllEntities() async throws {
        let metrics = try await GlassnodeSwift.fetchAllMetrics()
        MetricEntityQuery.allEntities = metrics.data.map {
            MetricAppEntity(
                id: "\($0.id)",
                name: $0.attributes.name,
                shortName: $0.attributes.shortName,
                metricAssets: $0.attributes.metricAssets.data.map { asset in
                    asset.attributes.symbol
                },
                metricPath: $0.attributes.path
            )
        }
    }
    
    static func getAllEntities() async throws -> [MetricAppEntity]? {
        if MetricEntityQuery.allEntities != nil {
            return MetricEntityQuery.allEntities
        }
        try await fetchAndCacheAllEntities()
        return MetricEntityQuery.allEntities
    }
    
    func entities(for identifiers: [MetricAppEntity.ID]) async throws -> [MetricAppEntity] {
        MetricEntityQuery.allEntities?.filter { identifiers.contains($0.id) } ?? []
    }
    
    func suggestedEntities() async throws -> [MetricAppEntity] {
        MetricEntityQuery.allEntities?.sorted { $0.name < $1.name } ?? []
    }
    
    func defaultResult() async -> MetricAppEntity? {
        MetricEntityQuery.allEntities?.first
    }
}
