//
//  BotCheckView.swift
//  TradeApp
//
//  Created by egor_dmitriev on 04.06.2026.
//

import Foundation
import SwiftUI
 
// MARK: - Model
enum SwipeDirection: CaseIterable {
   case up, down, left, right
 
   var title: String {
      switch self {
      case .up: return "снизу вверх ↑"
      case .down: return "сверху вниз ↓"
      case .left: return "справа налево ←"
      case .right: return "слева направо →"
      }
   }
 
   // Цвет подсветки поля при движении пальцем
   var highlightColor: Color {
      switch self {
      case .up: return .blue
      case .down: return .green
      case .left: return .orange
      case .right: return .purple
      }
   }
}
 
// MARK: - BotCheckView
struct BotCheckView: View {
   var onSuccess: () -> Void
   var onFailure: () -> Void
 
   // MARK: Private state
   @State private var steps: [SwipeDirection] = BotCheckView.generateSteps()
   @State private var currentStep: Int = 0
 
   @State private var highlightColor: Color = .clear
   @State private var isHighlighted: Bool   = false
 
   @State private var results: [Bool] = []
 
   private static let totalSteps = 3
 
   private static func generateSteps() -> [SwipeDirection] {
      var all = SwipeDirection.allCases
      all.shuffle()
      return Array(all.prefix(totalSteps))
   }
 
   // MARK: - Body
   var body: some View {
      ZStack {
         Color.black.opacity(0.5)
            .ignoresSafeArea()
 
         VStack(spacing: 20) {
            VStack(spacing: 6) {
               Text("Проверка: я не бот")
                  .font(.title3).bold()
               Text("Шаг \(currentStep + 1) из \(Self.totalSteps)")
                  .font(.caption)
                  .foregroundColor(.secondary)
            }
 
            HStack(spacing: 6) {
               ForEach(0..<Self.totalSteps, id: \.self) { i in
                  Capsule()
                     .fill(stepColor(i))
                     .frame(height: 4)
                     .animation(.easeInOut(duration: 0.3), value: results.count)
               }
            }
 
            Divider()
 
            VStack(spacing: 4) {
               Text("Следующая команда:")
                  .font(.footnote)
                  .foregroundColor(.secondary)
               Text(steps[currentStep].title)
                  .font(.title2).bold()
                  .transition(.asymmetric(
                     insertion: .move(edge: .trailing).combined(with: .opacity),
                     removal:   .move(edge: .leading).combined(with: .opacity)
                  ))
                  .id(currentStep)   // смена id триггерит transition
                  .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
 
            // Поле для свайпа
            swipeField
 
         }
         .padding(24)
         .background(
            RoundedRectangle(cornerRadius: 20)
               .fill(Color(uiColor: .systemBackground))
               .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
         )
         .padding(.horizontal, 20)
      }
   }
 
   // MARK: - Swipe field
   private var swipeField: some View {
      RoundedRectangle(cornerRadius: 16)
         .fill(isHighlighted
            ? highlightColor.opacity(0.3)
            : Color(uiColor: .secondarySystemBackground)
         )
         .overlay(
            RoundedRectangle(cornerRadius: 16)
               .stroke(Color(uiColor: .separator), lineWidth: 1)
         )
         .overlay(
            Text("Проведите пальцем здесь")
               .font(.footnote)
               .foregroundColor(Color(uiColor: .tertiaryLabel))
               .opacity(isHighlighted ? 0 : 1)
         )
         .frame(height: 200)
         .animation(.easeInOut(duration: 0.15), value: isHighlighted)
         .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
               .onChanged { value in
                  if !isHighlighted {
                     isHighlighted = true
                     highlightColor = steps[currentStep].highlightColor
                  }
               }
               .onEnded { value in
                  isHighlighted = false
                  handleSwipe(translation: value.translation)
               }
         )
   }
 
   // MARK: - Swipe logic
   private func handleSwipe(translation: CGSize) {
      let detected = detectDirection(translation: translation)
      let expected = steps[currentStep]
      let correct  = detected == expected
 
      withAnimation(.easeInOut(duration: 0.3)) {
         results.append(correct)
      }
 
      if currentStep + 1 < Self.totalSteps {
         withAnimation { currentStep += 1 }
      } else {
         let allCorrect = results.allSatisfy { $0 }
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if allCorrect { onSuccess() } else { onFailure() }
         }
      }
   }
 
   private func detectDirection(translation: CGSize) -> SwipeDirection {
      let dx = translation.width
      let dy = translation.height
 
      if abs(dx) > abs(dy) {
         return dx > 0 ? .right : .left
      } else {
         return dy > 0 ? .down : .up
      }
   }
 
   // MARK: - Helpers
   private func stepColor(_ index: Int) -> Color {
      guard index < results.count else {
         return index == currentStep ? Color.primary.opacity(0.3) : Color.primary.opacity(0.1)
      }
      return results[index] ? .green : .red
   }
}
