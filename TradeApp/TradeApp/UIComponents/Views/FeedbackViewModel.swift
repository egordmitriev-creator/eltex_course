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
 
// MARK: - ViewModel
final class FeedbackViewModel: ObservableObject {
 
   // MARK: - Input
   @Published var authorName: String = ""
   @Published var messageText: String = ""
   @Published var isConsentChecked: Bool = false
 
   // MARK: - UI State
   @Published var showConsent: Bool = false
   @Published var showSuccess: Bool = false
 
   // MARK: - Validation feedback
   @Published private(set) var authorError: String? = nil
   @Published private(set) var messageError: String? = nil
   @Published private(set) var showErrors: Bool = false
 
   // MARK: - Derived state
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
         .sink { [weak self] value in
            self?.canSend = value
         }
         .store(in: &cancellables)
 
      $authorName
         .dropFirst()
         .combineLatest($showErrors)
         .sink { [weak self] _, showErrors in
            self?.authorError = showErrors ? self?.validateAuthor()?.rawValue : nil
         }
         .store(in: &cancellables)
 
      $messageText
         .dropFirst()
         .combineLatest($showErrors)
         .sink { [weak self] _, showErrors in
            self?.messageError = showErrors ? self?.validateMessage()?.rawValue : nil
         }
         .store(in: &cancellables)
   }
 
   // MARK: - Public interface
   func send() {
      showErrors = true
 
      authorError = validateAuthor()?.rawValue
      messageError = validateMessage()?.rawValue
 
      guard validate() == nil else { return }
 
      AppLogger.auth.info("Feedback submitted (author: \(self.authorName, privacy: .public))")
      showSuccess = true
   }
 
   func reset() {
      authorName = ""
      messageText = ""
      isConsentChecked = false
      showErrors = false
      authorError = nil
      messageError = nil
      showSuccess = false
   }
 
   // MARK: - Private validation
   private func validate() -> FeedbackValidationError? {
      if let e = validateAuthor() { return e }
      if let e = validateMessage() { return e }
      if !isConsentChecked { return .noConsent }
      return nil
   }
 
   private func validateAuthor() -> FeedbackValidationError? {
      let trimmed = authorName.trimmingCharacters(in: .whitespaces)
      if trimmed.isEmpty { return .emptyAuthor }
      if trimmed.count < 2 { return .shortAuthor }
      return nil
   }
 
   private func validateMessage() -> FeedbackValidationError? {
      let trimmed = messageText.trimmingCharacters(in: .whitespaces)
      if trimmed.isEmpty { return .emptyMessage }
      if trimmed.count < 10 { return .shortMessage }
      return nil
   }
}
 
