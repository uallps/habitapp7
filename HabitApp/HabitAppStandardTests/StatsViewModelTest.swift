//
//  StatsViewModelTest.swift
//  HabitAppStandardTests
//

import XCTest
@testable import HabitApp_Standard

@MainActor
final class StatsViewModelTest: XCTestCase {

    private func assertObservableObject<T: ObservableObject>(_ type: T.Type) {
        XCTAssertTrue(true)
    }

    func testStatsViewModel_TypeAvailable() {
        XCTAssertNotNil(StatsViewModel.self)
    }

    func testStatsViewModel_ConformsToObservableObject() {
        assertObservableObject(StatsViewModel.self)
    }
}
