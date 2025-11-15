//
//  FilterFeature.swift
//  PdfTest
//
//  Created by 송영민 on 11/15/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct FilterFeature {
    @ObservableState
    struct State: Equatable {
        var showNames = false
    }
    
    enum Action: Equatable {
        case toggleLongNames(Bool)
        case applyButtonTapped
        case cancelButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
        switch action {
        case let .toggleLongNames(value):
            state.showNames = value
            return .none
            
        case .applyButtonTapped:
            return .none
            
        case .cancelButtonTapped:
            return .none
            }
        }
    }
}

struct FilterView: View {
    @Bindable var store: StoreOf<FilterFeature>
    
    var body: some View {
        NavigationStack {
            Form {
                Toggle(
                    "이름이 5글자",
                    isOn: $store.showNames.sending(\.toggleLongNames)
                )
            }
            .navigationTitle("필터")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        store.send(.cancelButtonTapped)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("적용") {
                        store.send(.applyButtonTapped)
                    }
                }
            }
        }
    }
}
