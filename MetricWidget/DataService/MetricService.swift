//
//  DataService.swift
//  Glassnode At A Glance
//
//  Created by Ondrej Barta on 17.11.23.
//

import Foundation

struct Metric: Codable, Identifiable {
    let id: String // Assuming there's a unique identifier for each metric
    let group: String
    let shortName: String
    let tier: String
    let metricCode: String
    let path: String
    let isNew: Bool
    // Add other fields as per the JSON response
}

class MetricService {
    let urlString = "https://cms.glassnode.com/api/metric-assets/BTC/metrics?fields[0]=group&fields[1]=shortName&fields[2]=tier&fields[3]=metricCode&fields[4]=path&fields[5]=isNew&populate[0]=metric_assets&populate[1]=studio_metric_config&populate[2]=metric_categories"
    
    func fetchMetrics(completion: @escaping ([Metric]?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let metrics = try JSONDecoder().decode([Metric].self, from: data)
                completion(metrics)
            } catch {
                completion(nil)
            }
        }
        
        task.resume()
    }
}

