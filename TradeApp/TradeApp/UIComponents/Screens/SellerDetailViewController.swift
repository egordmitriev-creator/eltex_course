//
//  SellerDetailViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 09.05.2026.
//

import Foundation
import UIKit
 
final class SellerDetailViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
 
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let onlineIndicator = UIView()
 
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let ratingStack = UIStackView()
    private let ratingLabel = UILabel()
    private let starsLabel = UILabel()
 
    private let statsCard = UIView()
    private let dealsLabel = UILabel()
    private let reserveLabel = UILabel()
    private let rateLabel = UILabel()
    private let regDateLabel = UILabel()
 
    private let currenciesCard = UIView()
    private let currenciesTitle = UILabel()
    private let currenciesStack = UIStackView()
 
    // MARK: - Dependencies
    private let viewModel: SellerDetailViewModel
 
    // MARK: - Init
    init(viewModel: SellerDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
 
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
 
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populate()
    }
 
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = viewModel.sellerName
 
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
 
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
 
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
 
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
 
        buildHeader()
        buildStatsCard()
        buildCurrenciesCard()
    }
 
    private func buildHeader() {
        // Avatar circle
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.backgroundColor = .systemBlue
        avatarView.layer.cornerRadius = 40
 
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.textColor = .white
        avatarLabel.font = .systemFont(ofSize: 28, weight: .bold)
        avatarLabel.textAlignment = .center
 
        onlineIndicator.translatesAutoresizingMaskIntoConstraints = false
        onlineIndicator.layer.cornerRadius = 8
        onlineIndicator.layer.borderWidth = 2
        onlineIndicator.layer.borderColor = UIColor.systemGroupedBackground.cgColor
 
        avatarView.addSubview(avatarLabel)
        avatarView.addSubview(onlineIndicator)
 
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80),
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            onlineIndicator.widthAnchor.constraint(equalToConstant: 16),
            onlineIndicator.heightAnchor.constraint(equalToConstant: 16),
            onlineIndicator.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: -2),
            onlineIndicator.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: -2)
        ])
 
        // Name + status
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textAlignment = .center
 
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
 
        // Rating
        ratingStack.axis = .horizontal
        ratingStack.spacing = 6
        ratingStack.alignment = .center
 
        ratingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        starsLabel.font = .systemFont(ofSize: 14)
 
        ratingStack.addArrangedSubview(starsLabel)
        ratingStack.addArrangedSubview(ratingLabel)
 
        // Wrapper for centering
        let ratingWrapper = UIStackView(arrangedSubviews: [ratingStack])
        ratingWrapper.axis = .horizontal
        ratingWrapper.alignment = .center
        ratingWrapper.distribution = .equalCentering
 
        // Header stack
        let headerStack = UIStackView(arrangedSubviews: [avatarView, nameLabel, statusLabel, ratingWrapper])
        headerStack.axis = .vertical
        headerStack.spacing = 6
        headerStack.alignment = .center
 
        contentStack.addArrangedSubview(headerStack)
    }
 
    private func buildStatsCard() {
        statsCard.backgroundColor = .secondarySystemGroupedBackground
        statsCard.layer.cornerRadius = 14
 
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
 
        let title = makeSectionTitle("Статистика")
        stack.addArrangedSubview(title)
 
        dealsLabel.numberOfLines = 0
        reserveLabel.numberOfLines = 0
        rateLabel.numberOfLines = 0
        regDateLabel.numberOfLines = 0
 
        [dealsLabel, rateLabel, reserveLabel, regDateLabel].forEach {
            $0.font = .systemFont(ofSize: 15)
            stack.addArrangedSubview($0)
        }
 
        statsCard.addSubview(stack)
 
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: statsCard.topAnchor),
            stack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor)
        ])
 
        contentStack.addArrangedSubview(statsCard)
    }
 
    private func buildCurrenciesCard() {
        currenciesCard.backgroundColor = .secondarySystemGroupedBackground
        currenciesCard.layer.cornerRadius = 14
 
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
 
        let title = makeSectionTitle("Предпочтительные валюты")
        stack.addArrangedSubview(title)
 
        currenciesStack.axis = .horizontal
        currenciesStack.spacing = 8
        stack.addArrangedSubview(currenciesStack)
 
        currenciesCard.addSubview(stack)
 
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: currenciesCard.topAnchor),
            stack.leadingAnchor.constraint(equalTo: currenciesCard.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: currenciesCard.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: currenciesCard.bottomAnchor)
        ])
 
        contentStack.addArrangedSubview(currenciesCard)
    }
 
    // MARK: - Populate
    private func populate() {
        let vm = viewModel
 
        // Avatar
        avatarLabel.text = String(vm.sellerName.prefix(2)).uppercased()
        onlineIndicator.backgroundColor = vm.isOnline ? .systemGreen : .systemGray
 
        // Header
        nameLabel.text = vm.sellerName
        statusLabel.text = vm.onlineStatus
 
        // Stars
        let filled = Int(vm.rating.rounded())
        let stars = String(repeating: "★", count: filled) + String(repeating: "☆", count: 5 - filled)
        starsLabel.text = stars
        starsLabel.textColor = .systemYellow
        ratingLabel.text = vm.ratingFormatted
 
        // Stats
        dealsLabel.attributedText = makeStatRow(key: "Сделок завершено:", value: "\(vm.completedDeals)")
        rateLabel.attributedText = makeStatRow(key: "Курс:", value: vm.rateFormatted)
        reserveLabel.attributedText = makeStatRow(key: "Резерв:", value: vm.reserveFormatted)
        regDateLabel.attributedText = makeStatRow(key: "На платформе с:", value: vm.registrationDateFormatted)
 
        // Currencies
        vm.preferredCurrencies.forEach { code in
            let badge = makeCurrencyBadge(code)
            currenciesStack.addArrangedSubview(badge)
        }
    }
 
    // MARK: - Helpers
    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textTransform(uppercase: true)
        return label
    }
 
    private func makeStatRow(key: String, value: String) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: key + " ",
            attributes: [.foregroundColor: UIColor.secondaryLabel,
                         .font: UIFont.systemFont(ofSize: 15)]
        )
        result.append(NSAttributedString(
            string: value,
            attributes: [.foregroundColor: UIColor.label,
                         .font: UIFont.systemFont(ofSize: 15, weight: .medium)]
        ))
        return result
    }
 
    private func makeCurrencyBadge(_ code: String) -> UIView {
        let label = UILabel()
        label.text = code
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemBlue
        label.textAlignment = .center
 
        let container = UIView()
        container.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        container.layer.cornerRadius = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
 
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
        ])
        return container
    }
}
 
// MARK: - UILabel extension helper (uppercase transform)
private extension UILabel {
    func textTransform(uppercase: Bool) {
        if uppercase, let t = text {
            text = t.uppercased()
        }
    }
}
