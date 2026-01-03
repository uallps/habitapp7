import Foundation
import SwiftUI
import SwiftData
import UserNotifications

struct HabitListView: View {
    @StateObject private var viewModel: HabitListViewModel
    @EnvironmentObject private var appConfig: AppConfig
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isAddingHabit = false
    @State private var habitToEdit: Habit?
    @State private var isAddingCategory = false
    @State private var availableCategories: [Category] = []
    @State private var categoryFilter: CategoryFilter = .all
    @State private var showDeleteConfirmation = false
    @State private var habitToDelete: Habit?

    init(storageProvider: StorageProvider) {
        _viewModel = StateObject(wrappedValue: HabitListViewModel(storageProvider: storageProvider))
}

private enum CategoryFilter: Equatable {
    case all
    case category(UUID)
    case uncategorized
}

    var body: some View {
        let headerViews = PluginRegistry.shared.getHabitListHeaderViews()
        let footerViews = PluginRegistry.shared.getHabitListFooterViews()
        let habits = viewModel.habits
        let today = Date()
        let categoriesByHabitId = appConfig.showCategories
            ? viewModel.categoryByHabitId(for: habits)
            : [:]
        let hasUncategorized = appConfig.showCategories &&
            habits.contains { categoriesByHabitId[$0.id] == nil }
        let filteredHabits = applyCategoryFilter(
            habits: habits,
            categoriesByHabitId: categoriesByHabitId
        )
        let todayHabits = sortHabitsByTitle(
            filteredHabits.filter { $0.shouldBeCompletedOn(date: today) }
        )
        let otherHabits = sortHabitsByTitle(
            filteredHabits.filter { !$0.shouldBeCompletedOn(date: today) }
        )

        NavigationStack {
            ZStack {
                backgroundView

                VStack(spacing: 0) {
                    headerView

                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            if !headerViews.isEmpty {
                                ForEach(headerViews.indices, id: \.self) { index in
                                    headerViews[index]
                                }
                                .padding(.bottom, 4)
                            }

                            if appConfig.showCategories {
                                categoryFilterView(hasUncategorized: hasUncategorized)
                            }

                            sectionHeader("Para hoy")
                            ForEach(todayHabits) { habit in
                                HabitRowView(
                                    habit: habit,
                                    toggleCompletion: {
                                        viewModel.toggleCompletion(habit: habit)
                                    },
                                    onEdit: {
                                        habitToEdit = habit
                                    },
                                    onDelete: {
                                        confirmDelete(habit)
                                    },
                                    isCompletionEnabled: true,
                                    isInactive: false
                                )
                            }

                            sectionHeader("Otros dias")
                            ForEach(otherHabits) { habit in
                                HabitRowView(
                                    habit: habit,
                                    toggleCompletion: { },
                                    onEdit: {
                                        habitToEdit = habit
                                    },
                                    onDelete: {
                                        confirmDelete(habit)
                                    },
                                    isCompletionEnabled: false,
                                    isInactive: true
                                )
                            }
                        }
                        .padding(.horizontal, contentPadding)
                        .padding(.top, isCompactLayout ? 12 : 16)
                        .padding(.bottom, 120)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBarView(footerViews: footerViews)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isAddingHabit) {
                HabitModifyView(viewModel: viewModel)
            }
            .sheet(item: $habitToEdit) { habit in
                HabitModifyView(viewModel: viewModel, habitToEdit: habit)
            }
            .sheet(isPresented: $isAddingCategory) {
                CreateCategoryView { newCategory in
                    print("Categoria creada: \(newCategory.name)")
                    loadCategories()
                } onDelete: {
                    viewModel.reloadHabits()
                    loadCategories()
                }
            }
            .alert("Eliminar Habito", isPresented: $showDeleteConfirmation) {
                Button("Eliminar", role: .destructive) {
                    if let habit = habitToDelete {
                        viewModel.deleteHabit(habit)
                    }
                    habitToDelete = nil
                }
                Button("Cancelar", role: .cancel) {
                    habitToDelete = nil
                }
            } message: {
                Text("Esta accion no se puede deshacer.")
            }
            .onAppear {
                if appConfig.enableReminders {
                    UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

                    if let context = SwiftDataContext.shared {
                        ReminderManager.shared.configure(
                            modelContext: context,
                            enableReminders: appConfig.enableReminders
                        )

                        ReminderManager.shared.scheduleDailyHabitNotificationDebounced()
                    }
                }
                loadCategories()
            }
            .onChange(of: hasUncategorized) { newValue in
                if !newValue, categoryFilter == .uncategorized {
                    categoryFilter = .all
                }
            }
            .onChange(of: isAddingCategory) { newValue in
                if !newValue {
                    loadCategories()
                }
            }
        }
    }

    private func confirmDelete(_ habit: Habit) {
        habitToDelete = habit
        showDeleteConfirmation = true
    }

    private func sortHabitsByTitle(_ habits: [Habit]) -> [Habit] {
        habits.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    private func applyCategoryFilter(
        habits: [Habit],
        categoriesByHabitId: [UUID: Category]
    ) -> [Habit] {
        switch categoryFilter {
        case .all:
            return habits
        case .uncategorized:
            return habits.filter { categoriesByHabitId[$0.id] == nil }
        case .category(let categoryId):
            return habits.filter { categoriesByHabitId[$0.id]?.id == categoryId }
        }
    }

    private func loadCategories() {
        guard appConfig.showCategories,
              let context = SwiftDataContext.shared else {
            availableCategories = []
            categoryFilter = .all
            return
        }

        let descriptor = FetchDescriptor<Category>()
        let fetched = (try? context.fetch(descriptor)) ?? []
        let sorted = fetched.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        availableCategories = sorted
        if case let .category(selectedId) = categoryFilter,
           !sorted.contains(where: { $0.id == selectedId }) {
            categoryFilter = .all
        }
    }

    private var headerView: some View {
        HStack {
            Text("HabitApp")
                .font(.system(size: headerTitleSize, weight: .bold))
                .foregroundColor(primaryColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Today")
                    .font(.caption)
                    .foregroundColor(secondaryTextColor)
                    .textCase(.uppercase)

                Text(Self.dayFormatter.string(from: Date()))
                    .font(.system(size: headerDateSize, weight: .bold))
                    .foregroundColor(primaryTextColor)
            }
        }
        .padding(.horizontal, contentPadding)
        .padding(.vertical, isCompactLayout ? 12 : 16)
        .background(headerBackground.opacity(0.95))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(borderColor),
            alignment: .bottom
        )
        .shadow(
            color: reduceEffects ? .clear : Color.black.opacity(colorScheme == .dark ? 0.25 : 0.08),
            radius: reduceEffects ? 0 : 8,
            x: 0,
            y: reduceEffects ? 0 : 4
        )
    }

    @ViewBuilder
    private func bottomBarView(footerViews: [AnyView]) -> some View {
        VStack(spacing: 12) {
            if !footerViews.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(footerViews.indices, id: \.self) { index in
                            footerViews[index]
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }

            HStack(spacing: 12) {
                createHabitButton
                if appConfig.showCategories {
                    categoryButton
                }
            }
        }
        .padding(.horizontal, contentPadding)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(bottomBarBackground.opacity(0.95))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(borderColor),
            alignment: .top
        )
        .shadow(
            color: reduceEffects ? .clear : Color.black.opacity(colorScheme == .dark ? 0.35 : 0.15),
            radius: reduceEffects ? 0 : 16,
            x: 0,
            y: reduceEffects ? 0 : -6
        )
    }

    private var backgroundView: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            if !reduceEffects {
                Circle()
                    .fill(primaryColor.opacity(colorScheme == .dark ? 0.12 : 0.08))
                    .frame(width: isCompactLayout ? 360 : 460, height: isCompactLayout ? 360 : 460)
                    .blur(radius: 90)
                    .offset(x: -180, y: -260)

                Circle()
                    .fill(Color.blue.opacity(colorScheme == .dark ? 0.12 : 0.08))
                    .frame(width: isCompactLayout ? 300 : 360, height: isCompactLayout ? 300 : 360)
                    .blur(radius: 80)
                    .offset(x: 180, y: 220)
            }
        }
    }

    private func categoryFilterView(hasUncategorized: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(
                    title: "Todo",
                    isSelected: categoryFilter == .all
                ) {
                    categoryFilter = .all
                }

                ForEach(availableCategories, id: \.id) { category in
                    categoryChip(
                        title: category.name,
                        isSelected: categoryFilter == .category(category.id)
                    ) {
                        categoryFilter = .category(category.id)
                    }
                }

                if hasUncategorized {
                    categoryChip(
                        title: "Sin categoria",
                        isSelected: categoryFilter == .uncategorized
                    ) {
                        categoryFilter = .uncategorized
                    }
                }
            }
            .padding(.horizontal, 2)
        }
        .padding(.bottom, 4)
    }

    private func categoryChip(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? Color.white : primaryTextColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? primaryColor : chipBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? primaryColor.opacity(0.4) : chipBorderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(primaryTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    private var createHabitButton: some View {
        Button(action: {
            isAddingHabit = true
        }) {
            Label("Crear Habito", systemImage: "plus")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: buttonHeight)
                .background(primaryColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(
                    color: primaryColor.opacity(colorScheme == .dark ? 0.4 : 0.3),
                    radius: 12,
                    x: 0,
                    y: 6
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    private var categoryButton: some View {
        Button(action: {
            isAddingCategory = true
        }) {
            Text("Categoria")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(primaryTextColor)
                .frame(maxWidth: .infinity, minHeight: buttonHeight)
                .background(secondaryButtonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 1)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    private var primaryColor: Color {
        Color(red: 242 / 255, green: 120 / 255, blue: 13 / 255)
    }

    private var backgroundLight: Color {
        Color(red: 248 / 255, green: 247 / 255, blue: 245 / 255)
    }

    private var backgroundDark: Color {
        Color(red: 25 / 255, green: 18 / 255, blue: 14 / 255)
    }

    private var taskDark: Color {
        Color(red: 38 / 255, green: 26 / 255, blue: 20 / 255)
    }

    private var buttonUltraDark: Color {
        Color(red: 10 / 255, green: 6 / 255, blue: 4 / 255)
    }

    private var backgroundColor: Color {
        colorScheme == .dark
            ? backgroundDark
            : backgroundLight
    }

    private var headerBackground: Color {
        colorScheme == .dark
            ? taskDark
            : backgroundLight
    }

    private var bottomBarBackground: Color {
        colorScheme == .dark
            ? taskDark
            : backgroundLight
    }

    private var secondaryButtonBackground: Color {
        colorScheme == .dark
            ? buttonUltraDark
            : Color.white
    }

    private var chipBackground: Color {
        colorScheme == .dark ? taskDark : Color.white
    }

    private var chipBorderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.08)
    }

    private var borderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.08)
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? backgroundLight : Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)
    }

    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color(red: 199 / 255, green: 186 / 255, blue: 176 / 255) : .secondary
    }

    private var isCompactLayout: Bool {
        horizontalSizeClass == .compact
    }

    private var reduceEffects: Bool {
        reduceTransparency || reduceMotion || ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    private var contentPadding: CGFloat {
        isCompactLayout ? 16 : 24
    }

    private var headerTitleSize: CGFloat {
        isCompactLayout ? 22 : 24
    }

    private var headerDateSize: CGFloat {
        isCompactLayout ? 12 : 14
    }

    private var buttonHeight: CGFloat {
        isCompactLayout ? 52 : 56
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}
