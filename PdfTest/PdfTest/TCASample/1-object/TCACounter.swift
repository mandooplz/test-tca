//
//  TCACounter.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import Foundation
import ComposableArchitecture


// MARK: Object
@Reducer
struct TCACounter {
    // MARK: state
    @ObservableState
    struct State: Equatable {
        var count: Int = 0
    }
    
    
    // MARK: action
    enum Action {
        case increment
        case decrement
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .increment:
                state.count += 1
                return .none

            case .decrement:
                state.count -= 1
                return .none
            }
        }
    }
}
