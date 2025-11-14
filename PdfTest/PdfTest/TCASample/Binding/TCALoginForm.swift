//
//  TCALoginForm.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import Foundation
import ComposableArchitecture


// MARK: Object
@Reducer
struct TCALoginForm {
    // MARK: state
    @ObservableState
    struct State: Equatable {
        @BindingState var email: String = ""
        @BindingState var password: String = ""
        var isLoading: Bool = false
        var isFormValid: Bool = false
    }
    
    
    // MARK: action
    enum Action: BindableAction {
        case binding(BindingAction<State>) // email, password 상태 바인딩
        case submit
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none // email, password 변경은 BindingReducer가 이미 처리
            case .submit:
                print("email: \(state.email), password: \(state.password) 제출 완료")
                return .none
            }
        }
    }
}
