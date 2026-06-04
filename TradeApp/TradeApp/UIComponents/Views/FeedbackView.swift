//
//  FeedbackView.swift
//  TradeApp
//
//  Created by egor_dmitriev on 27.05.2026.
//

import SwiftUI

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
            headerSection
            authorSection
            messageSection
            topicPickerSection
            consentSection
            sendButton
         }
         .padding(20)
      }
   }

   // MARK: - Sections
   private var headerSection: some View {
      VStack(alignment: .leading, spacing: 6) {
         Text("Не получается войти?")
            .font(.title2).bold()
         Text("Опишите проблему — мы поможем разобраться.")
            .font(.subheadline)
            .foregroundColor(.secondary)
      }
   }

   private var authorSection: some View {
      VStack(alignment: .leading, spacing: 6) {
         Label("Имя автора", systemImage: "person")
            .font(.footnote)
            .foregroundColor(.secondary)

         // $viewModel.authorName — @Binding к @Published свойству ViewModel
         TextField("Введите ваше имя", text: $viewModel.authorName)
            .textFieldStyle(.roundedBorder)
            .textContentType(.name)
            .autocorrectionDisabled()

            .overlay(
               RoundedRectangle(cornerRadius: 6)
                  .stroke(viewModel.authorError != nil ? Color.red : Color.clear, lineWidth: 1)
            )

         if let error = viewModel.authorError {
            errorLabel(error)
         }
      }
   }

   private var messageSection: some View {
      VStack(alignment: .leading, spacing: 6) {
         Label("Текст обращения", systemImage: "text.bubble")
            .font(.footnote)
            .foregroundColor(.secondary)

         TextEditor(text: $viewModel.messageText)
            .frame(minHeight: 140)
            .padding(6)
            .background(
               RoundedRectangle(cornerRadius: 8)
                  .stroke(viewModel.messageError != nil ? Color.red : Color(uiColor: .separator))
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

         if let error = viewModel.messageError {
            errorLabel(error)
         }
      }
   }

   private var consentSection: some View {
      HStack(alignment: .top, spacing: 10) {
         Image(systemName: viewModel.isConsentChecked
            ? "checkmark.square.fill"
            : "square"
         )
         .foregroundColor(viewModel.isConsentChecked ? .red : .secondary)
         .font(.title3)
         // Тап по иконке — переключает чекбокс через ViewModel
         .onTapGesture { viewModel.isConsentChecked.toggle() }

         consentText
      }
   }

   private var sendButton: some View {
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

   // MARK: - Consent text with tappable link
   private var consentText: some View {
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
      .onTapGesture { viewModel.isConsentChecked.toggle() }
      .overlay(
         GeometryReader { geo in
            Color.clear
               .contentShape(Rectangle())
               .frame(width: geo.size.width * 0.52, height: 20)
               .offset(x: geo.size.width * 0.13, y: 0)
               .onTapGesture { viewModel.showConsent = true }
         },
         alignment: .topLeading
      )
   }

   // MARK: - Helpers
   private func errorLabel(_ message: String) -> some View {
      Label(message, systemImage: "exclamationmark.circle")
         .font(.caption)
         .foregroundColor(.red)
   }
}
 
 
// MARK: - FeedbackView + topicPickerSection
private extension FeedbackView {
   var topicPickerSection: some View {
      FeedbackTopicPickerSwiftUIView(
         selectedIDs: Binding(
            get: { viewModel.selectedTopicIDs },
            set: { viewModel.updateSelectedTopics($0) }
         )
      )
   }
}

// MARK: - Preview
#Preview {
   NavigationStack {
      FeedbackView()
   }
}
