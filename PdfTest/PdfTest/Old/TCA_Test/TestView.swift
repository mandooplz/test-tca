//
//  TestView.swift
//  PdfTest
//
//  Created by 김민우 on 11/14/25.
//
import ComposableArchitecture
import SwiftUI


// MARK: Object
@Reducer
struct CounterFeature {
    // MARK: state
    @ObservableState
    struct State: Equatable {
        var count = 0
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

struct CounterView: View {
    let store: StoreOf<CounterFeature>

    var body: some View {
        VStack {
            Text("\(store.count)")
            HStack {
                Button("-") { store.send(.decrement) }
                Button("+") { store.send(.increment) }
            }
        }.font(.largeTitle)
    }
}


