//
//  TCATabhome.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import Foundation
import ComposableArchitecture


// 어떤 화면으로 나가야 하는지를 표현하는 트리 노드
//


// MARK: Object
@Reducer
struct TCATabhome {
    // MARK: state
    @ObservableState
    struct State {
        // UI 내비게이션에 사용되는 상태
        @Presents var destination: Destination.State?
        
        // 객체 상태
        var count: Int = 0
    }
    @Reducer
    enum Destination {
        case detail(DetailTab)
        case settings(SettingTab)
    }
    
    
    // MARK: action
    enum Action {
        // UI 변경 액션
        case destination(PresentationAction<Destination.Action>)
        case goToDetailTab
        case goToSettingTab
        
        // 객체 액션
        case increment
        case decrement
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                // UI 변경
            case .goToDetailTab:
                state.destination = .detail(.init())
                return .none
            case .goToSettingTab:
                state.destination = .settings(.init())
                return .none
                
                // 자식 리듀서 액션
            case .destination:
                print("destination의 액션이 실행되었습니다.")
                return .none
                
                // 상태 변경
            case .increment:
                state.count += 1
                return .none
            case .decrement:
                state.count -= 1
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
