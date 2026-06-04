//
//  FeedbackTopicPickerView.swift
//  TradeApp
//
//  Created by egor_dmitriev on 04.06.2026.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Model
struct FeedbackTopic: Identifiable {
  let id: String
  let title: String

  static let all: [FeedbackTopic] = [
     FeedbackTopic(id: "withdraw", title: "Проблема с выводом"),
     FeedbackTopic(id: "bot", title: "Проблема с ботом"),
     FeedbackTopic(id: "p2p", title: "P2P продавец не отвечает"),
     FeedbackTopic(id: "auth", title: "Не могу войти"),
     FeedbackTopic(id: "rates", title: "Неверный курс"),
     FeedbackTopic(id: "other", title: "Другое"),
  ]
}

// MARK: - Delegate (UIKit-протокол сохранён по заданию)
protocol FeedbackTopicPickerDelegate: AnyObject {
  func topicPicker(didChangeSelection selectedIDs: Set<String>)
}

// MARK: - SwiftUI View (используется в FeedbackView)
struct FeedbackTopicPickerSwiftUIView: View {
  let topics: [FeedbackTopic]
  @Binding var selectedIDs: Set<String>

  weak var delegate: (any FeedbackTopicPickerDelegate)?

  init(
     topics: [FeedbackTopic] = FeedbackTopic.all,
     selectedIDs: Binding<Set<String>>,
     delegate: (any FeedbackTopicPickerDelegate)? = nil
  ) {
     self.topics = topics
     self._selectedIDs = selectedIDs
     self.delegate = delegate
  }

  var body: some View {
     VStack(alignment: .leading, spacing: 8) {
        Text("Тема обращения")
           .font(.footnote)
           .foregroundColor(.secondary)

        let rows = stride(from: 0, to: topics.count, by: 2).map {
           Array(topics[$0..<min($0 + 2, topics.count)])
        }

        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
           HStack(spacing: 8) {
              ForEach(row) { topic in
                 chipButton(topic)
              }
              if row.count == 1 { Spacer() }
           }
        }
     }
     .onChange(of: selectedIDs) { newValue in
        delegate?.topicPicker(didChangeSelection: newValue)
     }
  }

  private func chipButton(_ topic: FeedbackTopic) -> some View {
     let isSelected = selectedIDs.contains(topic.id)
     return Text(topic.title)
        .font(.system(size: 13, weight: .medium))
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity)
        .background(
           RoundedRectangle(cornerRadius: 17)
              .fill(isSelected ? Color.red : Color.clear)
              .overlay(
                 RoundedRectangle(cornerRadius: 17)
                    .stroke(isSelected ? Color.red : Color(uiColor: .separator), lineWidth: 1)
              )
        )
        .onTapGesture {
           if selectedIDs.contains(topic.id) {
              selectedIDs.remove(topic.id)
           } else {
              selectedIDs.insert(topic.id)
           }
        }
  }
}
