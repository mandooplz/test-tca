# 2-binding — 폼 상태 바인딩

로그인 폼의 입력값을 TCA 상태와 양방향으로 연결하고, 검증 및 제출을 액션으로 나누었습니다.

## TCA 기능, 설명, 예시 코드

### 1. `BindableAction`과 `BindingReducer`
- 설명: 이메일·비밀번호 필드를 TCA 상태와 자동 동기화하기 위해 `BindingReducer()`를 리듀서 앞단에 둡니다.
```swift
@Reducer
struct TCALoginForm {
    @ObservableState
    struct State: Equatable {
        var email: String = ""
        var password: String = ""
        var isLoading: Bool = false
        var isFormValid: Bool = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case validate
        case submit
    }

    var body: some Reducer<State, Action> {
        BindingReducer() // 바인딩 변경은 여기서 선 처리

        Reduce { state, action in
            // 나머지 액션은 아래 기능에서 다룹니다.
        }
    }
}
```

### 2. SwiftUI 필드와 `StoreOf` 바인딩
- 설명: `@State var store`와 `$store.email` 같은 최신 바인딩 구문으로 입력값을 직접 수정합니다.
```swift
struct TCALoginFormView: View {
    @State var store: StoreOf<TCALoginForm>

    var body: some View {
        TextField("Enter your mail", text: $store.email)
            .textInputAutocapitalization(.none)
            .onChange(of: store.email, initial: true) {
                store.send(.validate)
            }

        SecureField("Enter your password", text: $store.password)
            .onChange(of: store.password, initial: true) {
                store.send(.validate)
            }
    }
}
```

### 3. 검증/제출을 별도 액션으로 분리
- 설명: 입력값 변경과는 별도로 `.validate`, `.submit` 액션을 보내 폼 상태를 관리합니다.
```swift
Reduce { state, action in
    switch action {
    case .binding:
        return .none

    case .validate:
        let isEmailValid = state.email.contains("@")
        let isPasswordValid = state.password.count >= 6
        state.isFormValid = isEmailValid && isPasswordValid
        return .none

    case .submit:
        print("email: \(state.email), password: \(state.password) 제출 완료")
        return .none
    }
}
```
