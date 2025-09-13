//
//  LSSubscriptionConfiguration.swift
//  Markey
//
//  Created by Kerstin Haustein on 12/09/2025.
//

import LightstreamerClient

enum Fields: String {
    case ask = "ask"
    case bid = "bid"
    case itemStatus = "item_status"
    case lastPrice = "last_price"
    case max = "max"
    case min = "min"
    case open = "open_price"
    case percentChange = "pct_change"
    case referencePrice = "ref_price"
    case stockName = "stock_name"
    case time = "time"

    static var allCases: [Fields] {
        [.ask, .bid, .itemStatus, .lastPrice, .max, .min, .open, .percentChange, .referencePrice, .stockName, .time]
    }
}

struct LSSubscriptionConfiguration {
    let mode: LSSubscription.Mode
    let items: [String]
    let fields: [String]
    let dataAdapter: String
    let requestedSnapshot: LSSubscription.RequestedSnapshot

    init(mode: LSSubscription.Mode = .MERGE,
         items: [String] = defaultItemNames(),
         fields: [Fields] = [.stockName, .lastPrice, .percentChange],
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
