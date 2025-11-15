//
//  Tree_basedNavigation.swift
//  PdfTest
//
//  Created by 송영민 on 11/14/25.
//

import ComposableArchitecture
import Foundation


@Reducer
struct Tree_basedNavigation {

    // 1. 이 화면이 가지고 있을 상태
    @ObservableState
    struct State: Equatable {
        var count = 0
        var min = -10
        var max = 10
    }

    // 2. 이 화면에서 일어날 수 있는 액션들
    enum Action: Equatable {
        case plusButtonTapped
        case minusButtonTapped
        case resetButtonTapped
    }

    // 3. 액션을 받아서 상태를 어떻게 바꿀지 정하는 Reducer
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            
            let oldState = state
            
            
            switch action {
            case .plusButtonTapped:
                if state.count < state.max {
                    state.count += 1
                }
            case .minusButtonTapped:
                if state.count > state.min {
                    state.count -= 1
                }
            case .resetButtonTapped:
                state.count = 0
            }
            
            print("Action 확인: ", action)
            print("Old State 확인", oldState.count)
            print("New State", state.count)
            
            return .none
        }
    }
}
