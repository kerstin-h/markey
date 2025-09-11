//
//  ContentViewCoordinator.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

final class ContentViewCoordinator {
    func instantiate() -> ContentView {
        let dataProvider = LightstreamerDataProvider()
        return ContentView(contentViewModel: ContentViewModel(streamingDataProvider: dataProvider))
    }
}
