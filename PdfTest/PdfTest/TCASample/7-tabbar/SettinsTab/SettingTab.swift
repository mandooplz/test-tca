//
//  SettingTab.swift
//  PdfTest
//
//  Created by 김민우 on 11/16/25.
//
import Foundation
import ComposableArchitecture


// MARK: Object
@Reducer
struct SettingTab {
    @ObservableState
    struct State: Equatable {
        
    }
    enum Action {
        // Setting 화면에서 발생하는 액션
        case increment
        case decrement
    }
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
