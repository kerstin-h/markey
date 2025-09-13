//
//  MarketsListView.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI
import SwiftData

struct MarketsListView: View {
    @ObservedObject private var viewModel: MarketsListViewModel
    
    init(viewModel: MarketsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: .zero) {
                List {
                    Section(header: header) {
                        ForEach(viewModel.marketList, id: \.stockName) { market in
                            HStack(spacing: 12) {
                                Text(market.stockName)
                                Spacer()
                                Text(market.lastPrice)
                                Text(market.changePercent)
                            }
                        }
                    }
                }
                Divider()
                Text("*Data based on a questionable sample of Lightstreamer demo stocks.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
            }
            .navigationTitle("Popular Markets*")
            .navigationBarTitleDisplayMode(.inline)
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.startStreaming()
        }
        .onDisappear {
            viewModel.stopStreaming()
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Text("Market Name")
            Spacer()
            Text("Stock Price")
            Text("Change")
        }
    }
}

#Preview {
    MarketsListView(viewModel: MarketsListViewModel.mock)
}

extension MarketsListViewModel {
    static var mock: MarketsListViewModel {
        RootCoordinator.createViewModel()
    }
}
