//
//  MarketsListViewCoordinator.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

final class MarketsListViewCoordinator {
    func instantiate() -> MarketsListView {
        let dataProvider = LightstreamerDataProvider()
        return MarketsListView(viewModel: MarketsListViewModel(streamingDataProvider: dataProvider))
    }
}
