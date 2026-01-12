//
//  ExpandedFrequencyTest.swift
//  HabitAppPremiumTests
//
//  Tests para NM_ExpandedFrequency (solo disponible en Premium)
//

import XCTest
@testable import HabitApp

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
