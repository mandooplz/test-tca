//
//  TCATodoCounter.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import Foundation
import ComposableArchitecture


// MARK: Object
@Reducer
struct TCATodoCounter {
    // MARK: state
    @ObservableState
    struct State: Equatable {
        var count = 0
        let target = 10
    }
    
    
    // MARK: action
    enum Action: Equatable {
        case increment
        case decrement
        
        case delegate(Delegate)
        enum Delegate: Equatable {
            case reachedTen
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increment:
                state.count += 1
                if state.count == state.target {
                    return .send(.delegate(.reachedTen))
                }
                return .none

            case .decrement:
                state.count = max(0, state.count - 1)
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
