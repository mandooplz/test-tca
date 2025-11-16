//
//  TCAViewer.swift
//  PdfTest
//
//  Created by 김민우 on 11/17/25.
//
import Foundation
import ComposableArchitecture


// MARK: Object
@Reducer
struct TCAViewer {
    // MARK: state
    @ObservableState
    struct State {
        var count: Int = 0
    }
    
    // MARK: action
    enum Action {
        
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
