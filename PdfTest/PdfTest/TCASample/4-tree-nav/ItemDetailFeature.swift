//
//  ItemDetailFeature.swift
//  PdfTest
//
//  Created by 송영민 on 11/15/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ItemDetailFeature {
    
    @ObservableState
    struct State: Equatable {
        let item: InventoryFeature.Item
    }
    
    enum Action: Equatable {
        case closeButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .none
            }
        }
    }
}

struct ItemDetailView: View {
    @Bindable var store: StoreOf<ItemDetailFeature>
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("아이템 상세")
                    .font(.title)
                
                Text(store.item.name)
                    .font(.headline)
            }
            .padding()
            .navigationTitle("상세 화면")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        store.send(.closeButtonTapped)
                    }
                }
            }
        }
    }
}
