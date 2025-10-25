//
//  MarketsListView.swift
//  Markey
//
//  Created by Kerstin Haustein on 11/09/2025.
//

import SwiftUI

struct MarketsListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var viewModel: MarketsListViewModel

    private let columns = [
        GridItem(.flexible(minimum: 150), alignment: .leading),
        GridItem(.flexible(minimum: 85), alignment: .trailing),
        GridItem(.flexible(minimum: 85), alignment: .trailing)
    ]

    init(viewModel: MarketsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        contentView
            .alert(.errorTitle, isPresented: $viewModel.showAlert) {
                Button(.alertOkButton, role: .cancel) { }
        } message: {
            Text(.errorMsgCannotRetrieveData)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                viewModel.startStreaming()
            case .inactive, .background:
                viewModel.stopStreaming()
            @unknown default: break
            }
        }
    }

    private var contentView: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: .zero) {
                marketsList
                bottomBanner
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(.navigationTitle)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [.accentColor, .accentColor.opacity(0.9)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .ignoresSafeArea()
    }

    private var marketsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .zero) {
                LazyVGrid(columns: columns, spacing: .zero) {
                    Section(header: marketsHeader) {
                        ForEach(viewModel.marketRowViewModels, id: \.stockName) { marketRow in
                            MarketRow(marketRow)
                        }
                        .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
        .background(
            LinearGradient(
                colors: [
                    .accentColor.opacity(0.3),
                    .accentColor.opacity(0.1),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var marketsHeader: some View {
        LazyVGrid(columns: columns, spacing: .zero) {
            Text(String(localized: .marketNameHeading).uppercased())
            Text(String(localized: .lastPriceHeading).uppercased())
            Text(String(localized: .changePercentHeading).uppercased())
        }
        .font(.system(size: 13))
        .foregroundColor(.accent)
        .padding(.bottom, 4)
    }

    private var bottomBanner: some View {
        VStack(spacing: 16) {
            Divider()
            Group {
                Text(.lightstreamerFootnotePrefix)
                    .foregroundColor(.gray)
                + Text(.lightstreamerLink)
                    .foregroundColor(.accentColor)
                    .underline()
                + Text(.lighstreamerFootnoteSuffix)
                    .foregroundColor(.gray)
            }
            .font(.system(size: 13))
            .padding(.horizontal, 16)
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
