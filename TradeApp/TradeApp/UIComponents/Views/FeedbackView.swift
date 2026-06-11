//
//  FeedbackView.swift
//  TradeApp
//
//  Created by egor_dmitriev on 27.05.2026.
//

import SwiftUI
import Combine
internal import os

// MARK: - Main View
struct FeedbackView: View {
    @StateObject private var viewModel = FeedbackViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            formContent
                .blur(radius: viewModel.showConsent ? 3 : 0)
                .allowsHitTesting(!viewModel.showConsent)
                .animation(.easeInOut(duration: 0.25), value: viewModel.showConsent)
            
            if viewModel.showConsent {
                ConsentOverlayView(isPresented: $viewModel.showConsent)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.showConsent)
        .navigationTitle("Обратная связь")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Отправлено", isPresented: $viewModel.showSuccess) {
            Button("Закрыть") { dismiss() }
        } message: {
            Text("Ваше обращение успешно отправлено. Мы свяжемся с вами в ближайшее время.")
        }
    }
    
    // MARK: - Form
    private var formContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Не получается войти?")
                        .font(.title2).bold()
                    Text("Опишите проблему — мы поможем разобраться.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Author field
                VStack(alignment: .leading, spacing: 6) {
                    Label("Имя автора", systemImage: "person")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    TextField("Введите ваше имя", text: $viewModel.authorName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                }
                
                // Message field
                VStack(alignment: .leading, spacing: 6) {
                    Label("Текст обращения", systemImage: "text.bubble")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    TextEditor(text: $viewModel.messageText)
                        .frame(minHeight: 140)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(uiColor: .separator))
                        )
                        .overlay(
                            Group {
                                if viewModel.messageText.isEmpty {
                                    Text("Опишите вашу проблему...")
                                        .foregroundColor(.init(.tertiaryLabel))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 13)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                // Consent checkbox
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: viewModel.isConsentChecked
                          ? "checkmark.square.fill"
                          : "square"
                    )
                    .foregroundColor(viewModel.isConsentChecked ? .red : .secondary)
                    .font(.title3)
                    .onTapGesture { viewModel.isConsentChecked.toggle() }
                    
                    consentText
                }
                
                // Send button
                Button(action: viewModel.send) {
                    HStack {
                        Spacer()
                        Text("Отправить")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .frame(height: 48)
                    .background(viewModel.canSend ? Color.red : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!viewModel.canSend)
                .animation(.easeInOut(duration: 0.2), value: viewModel.canSend)
                
            }
            .padding(20)
        }
    }
    
    // MARK: - Consent text with tappable link
    private var consentText: some View {
        // Разбиваем на части вручную — Text + Text = Text в SwiftUI
        (
            Text("Я согласен на ")
                .foregroundColor(.primary)
            + Text("обработку данных")
                .foregroundColor(.red)
                .underline()
            + Text(" в соответствии с политикой конфиденциальности.")
                .foregroundColor(.primary)
        )
        .font(.footnote)
        .onTapGesture(perform: handleConsentTextTap)
        // Перехватмтолько нажатия на «обработку данных» через overlay
        .overlay(
            GeometryReader { geo in
                // Прозрачная область поверх слова «обработку данных»
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: geo.size.width * 0.52, height: 20)
                    .offset(x: geo.size.width * 0.13, y: 0)
                    .onTapGesture { viewModel.showConsent = true }
            },
            alignment: .topLeading
        )
    }
    
    private func handleConsentTextTap() {
        // Если пользователь нажал вне зоны ссылки — просто переключаем чекбокс
        viewModel.isConsentChecked.toggle()
    }
}

// MARK: - ViewModel
final class FeedbackViewModel: ObservableObject {
    @Published var authorName: String = ""
    @Published var messageText: String = ""
    @Published var isConsentChecked: Bool = false
    @Published var showConsent: Bool = false
    @Published var showSuccess: Bool = false
    
    var canSend: Bool {
        isConsentChecked && !authorName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func send() {
        guard canSend else { return }
        AppLogger.auth.info("Feedback submitted (author: \(self.authorName))")
        
        showSuccess = true
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        FeedbackView()
    }
}
