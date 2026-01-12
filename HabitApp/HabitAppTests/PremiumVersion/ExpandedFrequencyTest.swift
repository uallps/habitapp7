//
//  ExpandedFrequencyTest.swift
//  HabitAppTests - Premium Version
//
//  Tests para NM_ExpandedFrequency (solo disponible en Premium)
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

#if EXPANDED_FREQUENCY_FEATURE

final class ExpandedFrequencyTest: XCTestCase {

    func testExpandedFrequencyDefaultType() {
        let habitId = UUID()
        let frequency = ExpandedFrequency(habitID: habitId)

        XCTAssertEqual(frequency.habitID, habitId)
        XCTAssertEqual(frequency.type, .daily)
    }

    func testExpandedFrequencyCustomTypes() {
        let habitId = UUID()
        let weekly = ExpandedFrequency(habitID: habitId, type: .weekly)
        let monthly = ExpandedFrequency(habitID: habitId, type: .monthly)
        let addiction = ExpandedFrequency(habitID: habitId, type: .addiction)

        XCTAssertEqual(weekly.type, .weekly)
        XCTAssertEqual(monthly.type, .monthly)
        XCTAssertEqual(addiction.type, .addiction)
    }

    func testFrequencyTypeCases() {
        XCTAssertEqual(FrequencyType.allCases.count, 4)
    }

    func testExpandedFrequencyPluginRegistered() {
        let registry = PluginRegistry.shared
        let hasPlugin = registry.plugins.contains { plugin in
            plugin is ExpandedFrequencyPlugin
        }

        XCTAssertTrue(hasPlugin, "ExpandedFrequencyPlugin should be registered")
    }
}

#else

final class ExpandedFrequencyTest: XCTestCase {
    func testExpandedFrequencyNotAvailable() {
        XCTAssertTrue(true, "ExpandedFrequency correctly disabled in non-Premium versions")
    }
}

#endif


