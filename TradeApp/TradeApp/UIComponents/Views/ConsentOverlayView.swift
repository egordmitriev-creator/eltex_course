//
//  ConsentOverlayView.swift
//  TradeApp
//
//  Created by egor_dmitriev on 27.05.2026.
//

import Foundation
import SwiftUI

struct ConsentOverlayView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 0) {
                HStack {
                    Text("Соглашение об обработке\nперсональных данных")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(20)
                
                Divider()
                
                ScrollView {
                    Text(consentText)
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .lineSpacing(5)
                        .padding(20)
                }
                .frame(maxHeight: 420)
                
                Divider()
                
                Button("Понятно") {
                    isPresented = false
                }
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 24, y: 8)
            )
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Consent text content
    private var consentText: String {
      """
      тут должен быть длинный юридический текст поэтоку:
      ЧАТ ГПТ УЛЬТРА МАКС ПОМОГИ НАПИСАТЬ НЕПОНЯТНЫЙ БОЛЬШОЙ ТЕКСТ ДЛЯ ДЕМОНСТРАЦИИ КОТОРЫЙ НИКТО НЕ БУДЕТ ЧИТАТЬ
      
      сятвя галочку вы продаёте мне всё своё имущество и душу (шутка, только душу)
      
      1. ОБЩИЕ ПОЛОЖЕНИЯ
      
      Настоящее Соглашение об обработке персональных данных (далее — Соглашение) регулирует порядок сбора, хранения, использования и защиты персональных данных пользователей приложения TradeApp.
      
      Используя форму обратной связи, вы подтверждаете своё согласие с условиями настоящего Соглашения.
      
      2. СОСТАВ ПЕРСОНАЛЬНЫХ ДАННЫХ
      
      В рамках формы обратной связи обрабатываются следующие данные:
      • имя автора обращения;
      • текст обращения;
      • дата и время отправки запроса.
      
      3. ЦЕЛИ ОБРАБОТКИ
      
      Персональные данные обрабатываются исключительно в целях:
      • рассмотрения обращений пользователей;
      • улучшения качества сервиса;
      • обеспечения технической поддержки.
      
      4. ХРАНЕНИЕ И ЗАЩИТА
      
      Данные хранятся на защищённых серверах и не передаются третьим лицам без вашего явного согласия, за исключением случаев, предусмотренных действующим законодательством.
      
      Срок хранения персональных данных — не более 3 лет с момента последнего обращения либо до отзыва согласия.
      
      5. ПРАВА ПОЛЬЗОВАТЕЛЯ
      
      Вы вправе в любое время:
      • запросить информацию о составе обрабатываемых данных;
      • потребовать исправления или удаления данных;
      • отозвать согласие на обработку, направив запрос по адресу support@tradeapp.example.
      
      6. ЗАКЛЮЧИТЕЛЬНЫЕ ПОЛОЖЕНИЯ
      
      Настоящее Соглашение вступает в силу с момента отправки формы обратной связи и действует бессрочно до его отзыва пользователем или изменения условий обработки.
      """
    }
}
