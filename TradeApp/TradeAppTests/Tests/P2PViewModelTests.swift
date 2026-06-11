//
//  P2PViewModelTests.swift
//  TradeAppTests
//
//  Created by egor_dmitriev on 18.05.2026.
//

import Foundation
import XCTest
@testable import TradeApp

final class P2PViewModelTests: XCTestCase {
    private var fetchMock: FetchOffersUseCaseMock!
    private var tradeMock: ExecuteTradeUseCaseMock!
    private var providerMock: CurrenciesDataProviderMock!
    private var coordinator: P2PCoordinatorMock!
    private var sut: P2PViewModel!

    override func setUp() {
        super.setUp()
        fetchMock    = FetchOffersUseCaseMock()
        tradeMock    = ExecuteTradeUseCaseMock()
        providerMock = CurrenciesDataProviderMock()
        coordinator  = P2PCoordinatorMock()

        sut = P2PViewModel(
            fetchOffersUseCase: fetchMock,
            executeTradeUseCase: tradeMock,
            dataProvider: providerMock
        )
        sut.coordinator = coordinator
    }

    override func tearDown() {
        sut          = nil
        fetchMock    = nil
        tradeMock    = nil
        providerMock = nil
        coordinator  = nil
        super.tearDown()
    }

    // MARK: — viewDidLoad
    func test_viewDidLoad_triggersLoadOffers() {
        sut.viewDidLoad()
        XCTAssertTrue(fetchMock.executeCalled,
                      "viewDidLoad должен вызывать FetchOffersUseCase.execute")
    }

    func test_viewDidLoad_stateBecomesLoaded_onSuccess() {
        let exp = expectation(description: "state == .loaded")
        sut.onStateChanged = { if case .loaded = $0 { exp.fulfill() } }
        sut.viewDidLoad()
        wait(for: [exp], timeout: 1)
    }

    func test_viewDidLoad_stateBecomesError_onFailure() {
        fetchMock.result = .failure(.noInternet)
        let exp = expectation(description: "state == .error")
        sut.onStateChanged = { if case .error = $0 { exp.fulfill() } }
        sut.viewDidLoad()
        wait(for: [exp], timeout: 1)
    }

    func test_viewDidLoad_walletUpdatedCalled_onSuccess() {
        let exp = expectation(description: "onWalletUpdated вызван")
        sut.onWalletUpdated = { _ in exp.fulfill() }
        sut.viewDidLoad()
        wait(for: [exp], timeout: 1)
    }

    // MARK: State transitions
    func test_loadingState_setBeforeFetchResult() {
        var states: [P2PScreenState] = []
        sut.onStateChanged = { states.append($0) }
        sut.viewDidLoad()
        let hasLoading = states.contains { if case .loading = $0 { return true }; return false }
        XCTAssertTrue(hasLoading, "Первым этапом должен быть .loading")
    }

    func test_loaded_offersCount_matchesMock() {
        let exp = expectation(description: "офферы загружены")
        sut.onStateChanged = { state in
            if case .loaded(let offers) = state {
                XCTAssertEqual(offers.count, 2)
                exp.fulfill()
            }
        }
        sut.viewDidLoad()
        wait(for: [exp], timeout: 1)
    }

    func test_error_message_notEmpty_onNoInternet() {
        fetchMock.result = .failure(.noInternet)
        let exp = expectation(description: "сообщение об ошибке")
        sut.onStateChanged = { state in
            if case .error(let msg) = state {
                XCTAssertFalse(msg.isEmpty)
                exp.fulfill()
            }
        }
        sut.viewDidLoad()
        wait(for: [exp], timeout: 1)
    }

    // MARK: didSelectOffer
    func test_didSelectOffer_callsExecuteTradeUseCase() {
        loadOffers()
        sut.didSelectOffer(at: 0, amountText: "100")
        XCTAssertTrue(tradeMock.executeCalled)
    }

    func test_didSelectOffer_passesCorrectAmount() {
        loadOffers()
        sut.didSelectOffer(at: 0, amountText: "77")
        XCTAssertEqual(tradeMock.lastInput?.amountText, "77")
    }

    func test_didSelectOffer_passesCorrectCurrencies() {
        loadOffers()
        sut.didSelectOffer(at: 0, amountText: "10")
        XCTAssertEqual(tradeMock.lastInput?.base,  "USD")
        XCTAssertEqual(tradeMock.lastInput?.quote, "EUR")
    }

    func test_didSelectOffer_onSuccess_callsOnWalletUpdated() {
        tradeMock.result = .success(())
        loadOffers()
        let exp = expectation(description: "кошелёк обновлён после сделки")
        sut.onWalletUpdated = { _ in exp.fulfill() }
        sut.didSelectOffer(at: 0, amountText: "50")
        wait(for: [exp], timeout: 1)
    }

    func test_didSelectOffer_onFailure_callsOnTradeError() {
        tradeMock.result = .failure(.invalidAmount)
        loadOffers()
        let exp = expectation(description: "ошибка сделки получена")
        sut.onTradeError = { _ in exp.fulfill() }
        sut.didSelectOffer(at: 0, amountText: "abc")
        wait(for: [exp], timeout: 1)
    }

    func test_didSelectOffer_ignoredWhenNotLoaded() {
        sut.didSelectOffer(at: 0, amountText: "100")
        XCTAssertFalse(tradeMock.executeCalled, "В состоянии .idle useCase не должен вызываться")
    }

    // MARK: Trade error messages
    func test_tradeError_insufficientFunds_containsAvailableAmount() {
        tradeMock.result = .failure(.insufficientFunds(available: 42.5))
        loadOffers()
        let exp = expectation(description: "сообщение о недостатке средств")
        sut.onTradeError = { msg in
            XCTAssertTrue(msg.contains("42.50"),
                          "Сообщение должно содержать доступный баланс «42.50»")
            exp.fulfill()
        }
        sut.didSelectOffer(at: 0, amountText: "999")
        wait(for: [exp], timeout: 1)
    }

    func test_tradeError_networkError_messageNotEmpty() {
        tradeMock.result = .failure(.networkError(.noInternet))
        loadOffers()
        let exp = expectation(description: "сетевая ошибка")
        sut.onTradeError = { msg in
            XCTAssertFalse(msg.isEmpty)
            exp.fulfill()
        }
        sut.didSelectOffer(at: 0, amountText: "10")
        wait(for: [exp], timeout: 1)
    }

    // MARK: didTapSellerInfo
    func test_didTapSellerInfo_callsCoordinator() {
        loadOffers()
        sut.didTapSellerInfo(at: 0)
        XCTAssertTrue(coordinator.showSellerDetailCalled)
    }

    func test_didTapSellerInfo_ignoredWhenNotLoaded() {
        sut.didTapSellerInfo(at: 0)
        XCTAssertFalse(coordinator.showSellerDetailCalled)
    }

    // MARK: didTapBack
    func test_didTapBack_callsCoordinatorDismiss() {
        sut.didTapBack()
        XCTAssertTrue(coordinator.dismissCalled)
    }

    // MARK: walletText
    func test_walletText_isNotEmpty() {
        XCTAssertFalse(sut.walletText.isEmpty)
    }

    func test_walletText_containsPipeSeparator() {
        XCTAssertTrue(sut.walletText.contains("|"))
    }

    // MARK: Helpers
    private func loadOffers() {
        let exp = expectation(description: "офферы загружены")
        sut.onStateChanged = { if case .loaded = $0 { exp.fulfill() } }
        sut.viewDidLoad()
        wait(for: [exp], timeout: 1)
    }
}
