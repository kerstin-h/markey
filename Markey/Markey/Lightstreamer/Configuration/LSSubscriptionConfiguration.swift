//
//  LSSubscriptionConfiguration.swift
//  Markey
//
//  Created by Kerstin Haustein on 12/09/2025.
//

import LightstreamerClient

enum Fields: String {
    case stockName = "stock_name"
    case lastPrice = "last_price"
}

struct LSSubscriptionConfiguration {
    let mode: LSSubscription.Mode
    let items: [String]
    let fields: [String]
    let dataAdapter: String
    let requestedSnapshot: LSSubscription.RequestedSnapshot

    init(mode: LSSubscription.Mode = .MERGE,
         items: [String] = defaultItemNames(),
         fields: [Fields] = [.stockName, .lastPrice],
         dataAdapter: String = "QUOTE_ADAPTER",
         requestedSnapshot: Bool = true) {
        self.mode = mode
        self.items = items
        self.fields = fields.map { $0.rawValue }
        self.dataAdapter = dataAdapter
        self.requestedSnapshot = requestedSnapshot ? .yes : .no
    }

    static func defaultItemNames(count: Int = 35) -> [String] {
        return (1...count).map { "item\($0)" }
    }
}
