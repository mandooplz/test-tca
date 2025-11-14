//
//  TCALoginFormView.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCALoginFormView: View {
    // MARK: core
    @State var store: StoreOf<TCALoginForm>
    
    
    // MARK: body
    var body: some View {
        VStack {
            Spacer()
            
            // 카드 영역
            VStack(alignment: .leading, spacing: 24) {
                // 타이틀
                Text("Login to your\naccount")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.primary)
                
                // 입력 필드
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Enter your mail", text: $store.email)
                        .textInputAutocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.6), lineWidth: 1.2)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .onChange(of: store.email, initial: true) {
                            store.send(.validate)
                        }
                    
                    SecureField("Enter your password", text: $store.password)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.6), lineWidth: 1.2)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .onChange(of: store.password, initial: true) {
                            store.send(.validate)
                        }
                }
                
                // 로그인 버튼
                Button {
                    store.send(.submit)
                } label: {
                    Group {
                        if store.isLoading {
                            ProgressView()
                        } else {
                            Text("Sign in")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .foregroundStyle(.white)
                .background(
                    Capsule()
                        .fill(store.isFormValid ? Color.accentColor : Color.accentColor.opacity(0.4))
                )
                .shadow(color: .black.opacity(store.isFormValid ? 0.12 : 0), radius: 8, x: 0, y: 4)
                .disabled(!store.isFormValid || store.isLoading)
                
                Spacer(minLength: 0)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
            )
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}



// MARK: Preview
#Preview {
    TCALoginFormView(
        store: Store(
            initialState: TCALoginForm.State()
        ) {
            TCALoginForm()
        }
    )
}
