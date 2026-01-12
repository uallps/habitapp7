//
//  SwiftDataTestCase.swift
//  HabitAppTests
//

import Foundation
import XCTest

@MainActor
class SwiftDataTestCase: XCTestCase {
    private static let lock = NSRecursiveLock()

    override func setUpWithError() throws {
        try super.setUpWithError()
        Self.lock.lock()
    }

    override func tearDownWithError() throws {
        Self.lock.unlock()
        try super.tearDownWithError()
    }
}
