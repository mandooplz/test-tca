//
//  Tree_basedNavigation.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

// 이건 그냥 제가 테스트

import ComposableArchitecture
import Foundation


@Reducer
struct CounterFeature {

    @ObservableState
    struct State: Equatable {
        var count = 0
    }

    enum Action: Equatable {
        case plusButtonTapped
        case minusButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .plusButtonTapped:
                state.count += 1
                return .none

            case .minusButtonTapped:
                state.count -= 1
                return .none
            }
        }
    }
}
