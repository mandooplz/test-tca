//
//  TCAController.swift
//  PdfTest
//
//  Created by 김민우 on 11/17/25.
//
import Foundation
import ComposableArchitecture


// MARK: Object
@Reducer
struct TCAController {
    // MARK: state
    @ObservableState
    struct State { }
    
    // MARK: action
    enum Action {
        case increment
        case decrement
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            // 액션을 TCAMainC을 통해 처리할 것이므로 필요없음.
            return .none
        }
    }
}
