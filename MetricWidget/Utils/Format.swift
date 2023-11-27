//
//  Format.swift
//  GlassnodeAtAGlance
//
//  Created by Ondrej Barta on 25.11.23.
//

import Foundation

func formatNumber(value: Double) -> String {
    let customFormatter = NumberFormatter()
    customFormatter.numberStyle = .decimal
    customFormatter.maximumFractionDigits = 2
    customFormatter.minimumFractionDigits = 0
    customFormatter.usesGroupingSeparator = true
    
    return customFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
}
