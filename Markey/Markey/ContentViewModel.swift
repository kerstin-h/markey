//
//  ContentViewModel.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

final class ContentViewModel {
    private let streamingDataProvider: LightstreamerDataProvider
    private var credentials: LSCredentials?
    
    init(streamingDataProvider: LightstreamerDataProvider) {
        self.streamingDataProvider = streamingDataProvider
        self.credentials = LSCredentials()
        startStreaming()
    }

    func startStreaming() {
        guard let credentials else { return }
        streamingDataProvider.instantiate(endpoint: credentials.endpoint)
        streamingDataProvider.connect()
        streamingDataProvider.subscribe()
    }
}
