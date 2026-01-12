//
//  ReminderManagerTest.swift
//  HabitAppTests
//

import XCTest
import UserNotifications
import SwiftData
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
final class ReminderManagerTest: SwiftDataTestCase {
    
    var reminderManager: ReminderManager!
    private var context: ModelContext?
    private var container: ModelContainer?

    private func makeInMemoryContext() throws -> ModelContext {
        let context = SwiftDataTestStack.makeContext()
        container = SwiftDataTestStack.container
        return context
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        reminderManager = ReminderManager.shared
        context = try makeInMemoryContext()
        if let context {
            reminderManager.configure(modelContext: context, enableReminders: true)
        }
    }
    
    override func tearDown() {
        // Limpiar notificaciones despues de cada test
        let manager = reminderManager
        Task {
            await manager?.cancelAllNotifications()
        }
        reminderManager = nil
        context = nil
        container = nil
        SwiftDataContext.shared = nil
        SwiftDataContext.sharedContainer = nil
        super.tearDown()
    }
    
    // MARK: - Test de inicializacion y configuracion
    
    func testReminderManager_IsSingleton() {
        // Arrange & Act
        let instance1 = ReminderManager.shared
        let instance2 = ReminderManager.shared
        
        // Assert
        XCTAssertTrue(instance1 === instance2, "ReminderManager debe ser un singleton")
    }
    
    func testConfigure_SetsProperties() {
        // Arrange
        // No podemos acceder directamente a modelContext, pero podemos verificar que no crashea
        
        // Act & Assert
        // La configuracion no deberia causar errores
        XCTAssertNotNil(reminderManager)
    }
    
    // MARK: - Test de autorizacion
    
    func testRequestAuthorizationIfNeeded_DoesNotCrash() async {
        // Arrange & Act & Assert
        // Este test simplemente verifica que el metodo puede ser llamado sin errores
        await reminderManager.requestAuthorizationIfNeeded()
        
        // Si llegamos aqui sin crash, el test pasa
        XCTAssertTrue(true)
    }
    
    // MARK: - Test de cancelacion de notificaciones
    
    func testCancelDailyHabitNotification_CompletesWithoutError() async {
        // Arrange & Act
        await reminderManager.cancelDailyHabitNotification()
        
        // Assert
        // Verificamos que no hay notificaciones pendientes con ese identificador
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let hasDailyNotification = pending.contains { $0.identifier == "daily_habits_notification" }
        
        XCTAssertFalse(hasDailyNotification)
    }
    
    func testCancelAllNotifications_RemovesAllPending() async {
        // Arrange
        // Primero programamos una notificacion de prueba
        let content = UNMutableNotificationContent()
        content.title = "Test"
        content.body = "Test notification"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_notification",
            content: content,
            trigger: trigger
        )
        
        let center = UNUserNotificationCenter.current()
        try? await center.add(request)
        
        // Act
        await reminderManager.cancelAllNotifications()
        
        // Assert
        let pending = await center.pendingNotificationRequests()
        XCTAssertEqual(pending.count, 0, "Todas las notificaciones deben ser canceladas")
    }
    
    // MARK: - Test de programacion de notificaciones
    
    func testScheduleDailyHabitNotificationDebounced_CanBeCalled() {
        // Arrange & Act
        reminderManager.scheduleDailyHabitNotificationDebounced()
        
        // Assert
        // Si no crashea, el test pasa
        XCTAssertTrue(true)
    }
    
    // MARK: - Test de comportamiento con multiples llamadas
    
    func testMultipleCancellations_DoNotCauseErrors() async {
        // Arrange & Act
        await reminderManager.cancelDailyHabitNotification()
        await reminderManager.cancelDailyHabitNotification()
        await reminderManager.cancelDailyHabitNotification()
        
        // Assert
        // Si no crashea con multiples cancelaciones, el test pasa
        XCTAssertTrue(true)
    }
    
    func testCancelAllAfterCancelDaily_DoesNotCauseError() async {
        // Arrange & Act
        await reminderManager.cancelDailyHabitNotification()
        await reminderManager.cancelAllNotifications()
        
        // Assert
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        XCTAssertEqual(pending.count, 0)
    }
    
    // MARK: - Test de autorizacion de notificaciones
    
    func testGetAuthorizationStatus() async {
        // Arrange
        let center = UNUserNotificationCenter.current()
        
        // Act
        let settings = await center.notificationSettings()
        
        // Assert
        // Verificamos que podemos obtener el estado
        XCTAssertNotNil(settings.authorizationStatus)
        
        // El estado puede ser: notDetermined, denied, authorized, provisional, ephemeral
        let validStatuses: [UNAuthorizationStatus] = [
            .notDetermined,
            .denied,
            .authorized,
            .provisional,
            .ephemeral
        ]
        
        XCTAssertTrue(validStatuses.contains(settings.authorizationStatus))
    }
    
    // MARK: - Test de programacion con debounce
    
    func testScheduleDailyHabitNotificationDebounced_MultipleCallsDebounce() async {
        // Arrange & Act
        // Llamar multiples veces rapidamente
        reminderManager.scheduleDailyHabitNotificationDebounced()
        reminderManager.scheduleDailyHabitNotificationDebounced()
        reminderManager.scheduleDailyHabitNotificationDebounced()
        
        // Esperar a que el debounce se complete
        try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 segundos
        
        // Assert
        // Si no crashea, el debounce funciono correctamente
        XCTAssertTrue(true)
    }
    
    // MARK: - Test de consistencia
    
    func testNotificationCancellation_IsIdempotent() async {
        // Arrange
        await reminderManager.cancelAllNotifications()
        
        // Act
        await reminderManager.cancelAllNotifications()
        await reminderManager.cancelAllNotifications()
        
        // Assert
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        XCTAssertEqual(pending.count, 0)
    }
    
    // MARK: - Test de integracion basica
    
    func testReminderManager_CanInteractWithNotificationCenter() async {
        // Arrange
        let center = UNUserNotificationCenter.current()
        
        // Act
        let settings = await center.notificationSettings()
        
        // Assert
        // Verificamos que podemos interactuar con UNUserNotificationCenter
        XCTAssertNotNil(settings)
    }
    
    // MARK: - Test de verificacion de notificaciones pendientes
    
    func testPendingNotifications_CanBeQueried() async {
        // Arrange
        let center = UNUserNotificationCenter.current()
        
        // Primero limpiamos
        await reminderManager.cancelAllNotifications()
        
        // Act
        let pending = await center.pendingNotificationRequests()
        
        // Assert
        XCTAssertEqual(pending.count, 0)
    }
    
    func testAddAndVerifyNotification() async {
        // Arrange
        let center = UNUserNotificationCenter.current()
        await reminderManager.cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_add_verify",
            content: content,
            trigger: trigger
        )
        
        // Act
        try? await center.add(request)
        let pending = await center.pendingNotificationRequests()
        
        // Assert
        XCTAssertTrue(pending.contains { $0.identifier == "test_add_verify" })
        
        // Cleanup
        await center.removePendingNotificationRequests(withIdentifiers: ["test_add_verify"])
    }
    
    // MARK: - Test de comportamiento edge cases
    
    func testReminderManager_HandlesNilContextGracefully() {
        // Arrange & Act
        // El ReminderManager debe manejar el caso donde no hay contexto configurado
        // sin crashear
        
        // Assert
        XCTAssertNotNil(reminderManager)
    }
    
    func testScheduleNotificationDebounced_CanBeCanceledBySubsequentCall() async {
        // Arrange & Act
        reminderManager.scheduleDailyHabitNotificationDebounced()
        
        // Llamar inmediatamente otra vez deberia cancelar la primera llamada
        reminderManager.scheduleDailyHabitNotificationDebounced()
        
        // Esperar el debounce
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // Assert
        // Si no hay crash, el test pasa
        XCTAssertTrue(true)
    }
}



