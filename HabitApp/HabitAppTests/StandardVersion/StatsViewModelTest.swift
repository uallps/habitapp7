//
//  StatsViewModelTest.swift
//  HabitAppTests
//

import XCTest
#if CORE_VERSION
@testable import HabitApp_Core
#elseif STANDARD_VERSION
@testable import HabitApp_Standard
#elseif PREMIUM_VERSION
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Premium)
@testable import HabitApp_Premium
#elseif canImport(HabitApp_Standard)
@testable import HabitApp_Standard
#elseif canImport(HabitApp_Core)
@testable import HabitApp_Core
#else
@testable import HabitApp
#endif

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
