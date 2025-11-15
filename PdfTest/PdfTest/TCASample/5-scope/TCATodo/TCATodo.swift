//
//  TCATodo.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//


import ComposableArchitecture
import Foundation

@Reducer
struct TCATodo {
    // MARK: state
    @ObservableState
    struct State: Equatable {
        var title: String = "공부하기"
        var isImportant: Bool = false
        var note: String = ""
    }
    
    
    // MARK: action
    enum Action: Equatable {
        case toggleImportant
        case setNote(String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleImportant:
                state.isImportant.toggle()
                return .none
                
            case let .setNote(text):
                state.note = text
                return .none
            }
        }
    }
}
