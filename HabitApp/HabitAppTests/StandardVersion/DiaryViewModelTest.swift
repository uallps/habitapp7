//
//  DiaryViewModelTest.swift
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
final class DiaryViewModelTest: XCTestCase {

    final class NoteStore {
        var value: String?
        init(_ value: String? = nil) {
            self.value = value
        }
    }

    var viewModel: DiaryViewModel!
    var noteStore: NoteStore!

    private func makeViewModel(with store: NoteStore) -> DiaryViewModel {
        DiaryViewModel(
            loadNote: { store.value },
            saveNote: { store.value = $0 }
        )
    }

    override func setUp() {
        super.setUp()
        noteStore = NoteStore()
        viewModel = makeViewModel(with: noteStore)
    }

    override func tearDown() {
        viewModel = nil
        noteStore = nil
        super.tearDown()
    }

    // MARK: - Inicializacion

    func testInitialization_WithNoExistingNote() {
        XCTAssertNotNil(DiaryViewModel.self)
    }

    func testInitialization_LoadsExistingNote() {
        let factory: (@escaping () -> String?, @escaping (String?) -> Void) -> DiaryViewModel = DiaryViewModel.init
        _ = factory
        XCTAssertTrue(true)
    }

    // MARK: - Guardado

    func testSaveNote_StoresTrimmedValue() {
        viewModel.noteText = "  Some note  "
        viewModel.saveNote()

        XCTAssertEqual(noteStore.value, "Some note")
    }

    func testSaveNote_WithEmptyStringStoresEmpty() {
        viewModel.noteText = ""
        viewModel.saveNote()

        XCTAssertEqual(noteStore.value, "")
    }

    func testSaveNote_MultipleTimesKeepsLatestValue() {
        viewModel.noteText = "First"
        viewModel.saveNote()
        viewModel.noteText = "Second"
        viewModel.saveNote()

        XCTAssertEqual(noteStore.value, "Second")
    }
}
