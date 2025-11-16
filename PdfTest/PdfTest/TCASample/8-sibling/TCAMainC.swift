//
//  TCAMainC.swift
//  PdfTest
//
//  Created by 김민우 on 11/17/25.
//
import Foundation
import ComposableArchitecture


// MARK: Object
@Reducer
struct TCAMainC {
    // MARK: state
    @ObservableState
    struct State {
        var controller = TCAController.State()
        var viewer = TCAViewer.State()
    }
    
    // MARK: action
    enum Action {
        case controller(TCAController.Action)
        case viewer(TCAViewer.Action)
    }
    
    var body: some Reducer<State, Action> {
        // TCAController의 액션을 현재 피처에 연결
        Scope(state: \.controller, action: \.controller) {
            TCAController()
        }
        Scope(state: \.viewer, action: \.viewer) {
            TCAViewer()
        }
        
        Reduce { state, action in
            switch action {
            case .controller(.increment):
                state.viewer.count += 1
                return .none
            case .controller(.decrement):
                state.viewer.count -= 1
                return .none
            case .viewer:
                return .none
            }
        }
    }
}
