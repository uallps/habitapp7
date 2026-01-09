import SwiftUI
import SwiftData

struct CalendarView: View {
    // Contexto
    private var context: ModelContext? { SwiftDataContext.shared }

    // Estado del mes visible
    @State private var visibleMonthAnchor: Date = Calendar.current.startOfMonth(for: Date())
    @State private var habits: [Habit] = []
    @State private var markedDaysCache: [Date: Bool] = [:] // cache por día (startOfDay)

    // Selección de día
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: Date())

    // Cache de categorías por hábito
    @State private var categoryNameByHabitId: [UUID: String] = [:]

    // Locale español para todo el calendario
    private let esLocale = Locale(identifier: "es_ES")

    var body: some View {
        // Evitar título duplicado: no usamos .navigationTitle, mostramos el mes solo en el header
        NavigationStack {
            VStack(spacing: 12) {
                header
                daysOfWeekHeader
                monthGrid

                Divider().padding(.vertical, 6)

                selectedDayHeader
                habitListForSelectedDay
            }
            .padding()
            .onAppear {
                loadHabitsIfNeeded()
                prefetchCategoriesForHabits()
                rebuildCache()
                selectedDay = Calendar.current.startOfDay(for: Date())
            }
            .onChange(of: visibleMonthAnchor) { _, _ in
                rebuildCache()
            }
            .onChange(of: habits) { _, _ in
                prefetchCategoriesForHabits()
                rebuildCache()
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation { visibleMonthAnchor = Calendar.current.monthByAdding(-1, to: visibleMonthAnchor) }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundColor(.orange) // botón anterior en naranja
            }

            Spacer()

            Text(monthYearTitle(for: visibleMonthAnchor))
                .font(.headline)

            Spacer()

            Button {
                withAnimation { visibleMonthAnchor = Calendar.current.monthByAdding(+1, to: visibleMonthAnchor) }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.orange) // botón siguiente en naranja
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Selector de mes")
        .accessibilityValue(monthYearTitle(for: visibleMonthAnchor))
    }

    private var daysOfWeekHeader: some View {
        let symbols = Calendar.current.shortWeekdaySymbolsShiftedToMonday(locale: esLocale)
        return HStack {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        let gridDates = Calendar.current.gridDatesForMonth(anchor: visibleMonthAnchor, weekStartsOnMonday: true)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(gridDates, id: \.self) { date in
                let isCurrentMonth = Calendar.current.isDate(date, equalTo: visibleMonthAnchor, toGranularity: .month)
                let isToday = Calendar.current.isDateInToday(date)
                let dayStart = Calendar.current.startOfDay(for: date)
                let isMarked = markedDaysCache[dayStart] ?? false
                let isSelected = Calendar.current.isDate(dayStart, inSameDayAs: selectedDay)

                CalendarDayCell(
                    date: date,
                    isInCurrentMonth: isCurrentMonth,
                    isToday: isToday,
                    isMarked: isMarked,
                    isSelected: isSelected,
                    locale: esLocale
                )
                .onTapGesture {
                    selectedDay = dayStart
                }
            }
        }
    }

    private var selectedDayHeader: some View {
        HStack {
            Text("Hábitos para \(dayTitle(for: selectedDay))")
                .font(.headline)
            Spacer()
        }
        .accessibilityLabel("Hábitos para el día seleccionado")
        .accessibilityValue(dayTitle(for: selectedDay))
    }

    private var habitListForSelectedDay: some View {
        let items = habitsFor(day: selectedDay)
        return Group {
            if items.isEmpty {
                Text("No hay hábitos para este día.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                List {
                    ForEach(items, id: \.id) { habit in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.title)
                                    .font(.body)
                                Text(categoryNameByHabitId[habit.id] ?? "Sin categoría")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                }
                .listStyle(.plain)
                .frame(minHeight: 200, maxHeight: 280)
            }
        }
    }

    // MARK: - Data

    private func loadHabitsIfNeeded() {
        guard habits.isEmpty, let context else { return }
        let descriptor = FetchDescriptor<Habit>()
        if let fetched = try? context.fetch(descriptor) {
            habits = fetched
        }
    }

    private func prefetchCategoriesForHabits() {
        guard let context else { return }
        let habitIds = habits.map(\.id)
        guard !habitIds.isEmpty else {
            categoryNameByHabitId = [:]
            return
        }

        let descriptor = FetchDescriptor<HabitCategoryFeature>(
            predicate: #Predicate { habitIds.contains($0.habitId) }
        )
        let features = (try? context.fetch(descriptor)) ?? []
        var names: [UUID: String] = [:]
        for feature in features {
            if let name = feature.category?.name {
                names[feature.habitId] = name
            }
        }
        categoryNameByHabitId = names
    }

    private func habitsFor(day: Date) -> [Habit] {
        habits
            // Filtra por fecha límite (si existe, el día debe ser <= endDate a nivel de día)
            .filter { habit in
                guard let limit = habit.endDate else { return true }
                // Compara por inicio de día para tratar la fecha como límite inclusivo
                let dayStart = Calendar.current.startOfDay(for: day)
                let limitStart = Calendar.current.startOfDay(for: limit)
                return dayStart <= limitStart
            }
            // Filtra por lógica de frecuencia/plugins
            .filter { $0.shouldBeCompletedOn(date: day) }
            .sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
    }

    private func rebuildCache() {
        markedDaysCache.removeAll(keepingCapacity: true)

        let days = Calendar.current.daysInMonth(anchor: visibleMonthAnchor)
        let startOfDays = days.map { Calendar.current.startOfDay(for: $0) }

        for day in startOfDays {
            var any = false
            for habit in habits {
                // Respeta fecha límite si existe
                if let limit = habit.endDate {
                    let dayStart = day
                    let limitStart = Calendar.current.startOfDay(for: limit)
                    if dayStart > limitStart {
                        continue // fuera del rango, no marcar
                    }
                }
                if habit.shouldBeCompletedOn(date: day) {
                    any = true
                    break
                }
            }
            markedDaysCache[day] = any
        }
    }

    // MARK: - Formatting (Español)

    private func monthYearTitle(for anchor: Date) -> String {
        let df = DateFormatter()
        df.locale = esLocale
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "LLLL 'de' yyyy"
        return df.string(from: anchor).capitalized
    }

    private func dayTitle(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = esLocale
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "EEEE d 'de' LLLL"
        return df.string(from: date).capitalized
    }
}
