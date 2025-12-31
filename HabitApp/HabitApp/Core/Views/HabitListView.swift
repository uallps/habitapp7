import Foundation
import SwiftUI
import UserNotifications

struct HabitListView: View {
    @StateObject private var viewModel: HabitListViewModel
    @EnvironmentObject private var appConfig: AppConfig
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var isAddingHabit = false
    @State private var habitToEdit: Habit?
    @State private var isAddingCategory = false
    @State private var categoryViewMode: CategoryViewMode = .create
    @State private var showDeleteConfirmation = false
    @State private var habitToDelete: Habit?

    init(storageProvider: StorageProvider) {
        _viewModel = StateObject(wrappedValue: HabitListViewModel(storageProvider: storageProvider))
    }

    var body: some View {
        let headerViews = PluginRegistry.shared.getHabitListHeaderViews()
        let footerViews = PluginRegistry.shared.getHabitListFooterViews()

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
                                let groupedHabits = viewModel.groupedHabitsByCategory()

                                ForEach(groupedHabits.keys.sorted(), id: \.self) { categoryName in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(categoryName)
                                            .font(.caption)
                                            .foregroundColor(secondaryTextColor)
                                            .padding(.leading, 4)

                                        ForEach(groupedHabits[categoryName] ?? []) { habit in
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
                                                }
                                            )
                                        }
                                    }
                                    .padding(.top, 6)
                                }
                            } else {
                                ForEach(viewModel.habits) { habit in
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
                                        }
                                    )
                                }
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
                CreateCategoryView(initialMode: categoryViewMode) { newCategory in
                    print("Categoria creada: \(newCategory.name)")
                } onDelete: {
                    viewModel.reloadHabits()
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

                        Task {
                            await ReminderManager.shared.scheduleDailyHabitNotification()
                        }
                    }
                }
            }
        }
    }

    private func confirmDelete(_ habit: Habit) {
        habitToDelete = habit
        showDeleteConfirmation = true
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
            color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.08),
            radius: 8,
            x: 0,
            y: 4
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
                    categoryMenuButton
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
            color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.15),
            radius: 16,
            x: 0,
            y: -6
        )
    }

    private var backgroundView: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

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

    private var categoryMenuButton: some View {
        Menu {
            Button {
                categoryViewMode = .create
                isAddingCategory = true
            } label: {
                Label("Crear categoria", systemImage: "plus")
            }
            Button(role: .destructive) {
                categoryViewMode = .delete
                isAddingCategory = true
            } label: {
                Label("Eliminar categoria", systemImage: "trash")
            }
        } label: {
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
