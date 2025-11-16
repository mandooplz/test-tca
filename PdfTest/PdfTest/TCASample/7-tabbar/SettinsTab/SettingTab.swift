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
        // Setting 화면에 필요한 상태
    }
    enum Action {
        // Setting 화면에서 발생하는 액션
    }
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            // Setting 로직
            return .none
        }
    }
}
