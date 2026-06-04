//
//  FeedbackViewModel.swift
//  TradeApp
//
//  Created by egor_dmitriev on 03.06.2026.
//

import Foundation
import Combine
internal import os

// MARK: - Validation Error
enum FeedbackValidationError: String {
   case emptyAuthor = "Введите имя автора"
   case shortAuthor = "Имя должно быть не короче 2 символов"
   case emptyMessage = "Введите текст обращения"
   case shortMessage = "Обращение должно быть не короче 10 символов"
   case noConsent = "Необходимо согласие на обработку данных"
}
 
// MARK: - Alert kind
enum FeedbackAlert: Identifiable {
   case success
   case botCheckFailed
 
   var id: String { "\(self)" }
 
   var title: String {
      switch self {
      case .success: return "Отправлено"
      case .botCheckFailed: return "Проверка не пройдена"
      }
   }
 
   var message: String {
      switch self {
      case .success:
         return "Ваше обращение успешно отправлено. Мы свяжемся с вами в ближайшее время."
      case .botCheckFailed:
         return "Попробуйте ещё раз."
      }
   }
}
 
// MARK: - ViewModel
final class FeedbackViewModel: ObservableObject {
   // MARK: - Input
   @Published var authorName: String = ""
   @Published var messageText: String = ""
   @Published var isConsentChecked: Bool = false
   @Published private(set) var selectedTopicIDs: Set<String> = []
 
   // MARK: - UI State
   @Published var showConsent: Bool = false
   @Published var showBotCheck: Bool = false
   @Published var activeAlert: FeedbackAlert? = nil
 
   // MARK: - Validation
   @Published private(set) var authorError: String? = nil
   @Published private(set) var messageError: String? = nil
   @Published private(set) var showErrors: Bool = false
 
   // MARK: - Derived
   @Published private(set) var canSend: Bool = false
 
   private var cancellables = Set<AnyCancellable>()
 
   // MARK: - Init
   init() {
      Publishers.CombineLatest3($authorName, $messageText, $isConsentChecked)
         .map { author, message, consent in
            consent
            && !author.trimmingCharacters(in: .whitespaces).isEmpty
            && !message.trimmingCharacters(in: .whitespaces).isEmpty
         }
         .sink { [weak self] in self?.canSend = $0 }
         .store(in: &cancellables)
 
      $authorName
         .dropFirst()
         .combineLatest($showErrors)
         .sink { [weak self] _, show in
            self?.authorError = show ? self?.validateAuthor()?.rawValue : nil
         }
         .store(in: &cancellables)
 
      $messageText
         .dropFirst()
         .combineLatest($showErrors)
         .sink { [weak self] _, show in
            self?.messageError = show ? self?.validateMessage()?.rawValue : nil
         }
         .store(in: &cancellables)
   }
 
   // MARK: - Public interface
   func send() {
      showErrors = true
      authorError = validateAuthor()?.rawValue
      messageError = validateMessage()?.rawValue
 
      guard validate() == nil else { return }
 
      showBotCheck = true
   }
 
   func botCheckPassed() {
      showBotCheck = false
      AppLogger.auth.info("Feedback submitted (author: \(self.authorName, privacy: .public))")
      activeAlert = .success
   }
 
   func botCheckFailed() {
      showBotCheck = false
      activeAlert = .botCheckFailed
   }
 
   /// Сброс формы — вызывается после успешной отправки
   func reset() {
      authorName = ""
      messageText = ""
      isConsentChecked = false
      selectedTopicIDs = []
      showErrors = false
      authorError = nil
      messageError = nil
   }
 
   func updateSelectedTopics(_ ids: Set<String>) {
      selectedTopicIDs = ids
   }
 
   // MARK: - Private validation
   private func validate() -> FeedbackValidationError? {
      if let e = validateAuthor() { return e }
      if let e = validateMessage() { return e }
      if !isConsentChecked { return .noConsent }
      return nil
   }
 
   private func validateAuthor() -> FeedbackValidationError? {
      let t = authorName.trimmingCharacters(in: .whitespaces)
      if t.isEmpty { return .emptyAuthor }
      if t.count < 2 { return .shortAuthor }
      return nil
   }
 
   private func validateMessage() -> FeedbackValidationError? {
      let t = messageText.trimmingCharacters(in: .whitespaces)
      if t.isEmpty { return .emptyMessage }
      if t.count < 10 { return .shortMessage }
      return nil
   }
}
