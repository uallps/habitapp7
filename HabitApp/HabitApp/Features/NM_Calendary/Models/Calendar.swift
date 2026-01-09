import Foundation

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }

    func monthByAdding(_ months: Int, to date: Date) -> Date {
        guard let result = self.date(byAdding: .month, value: months, to: date) else { return date }
        return startOfMonth(for: result)
    }

    func daysInMonth(anchor: Date) -> [Date] {
        guard
            let range = range(of: .day, in: .month, for: anchor),
            let monthStart = startOfDay(for: startOfMonth(for: anchor)) as Date?
        else { return [] }

        return range.compactMap { day -> Date? in
            date(byAdding: .day, value: day - 1, to: monthStart)
        }
    }

    // Devuelve una grilla completa (incluyendo días “padding” del mes anterior/siguiente)
    func gridDatesForMonth(anchor: Date, weekStartsOnMonday: Bool) -> [Date] {
        let monthDays = daysInMonth(anchor: anchor)
        guard let first = monthDays.first, let last = monthDays.last else { return [] }

        let firstWeekday = component(.weekday, from: first) // 1=Domingo...7=Sábado
        let lastWeekday = component(.weekday, from: last)

        // Ajuste para que la semana empiece en lunes si se solicita
        let leadingEmptyCount: Int = {
            if weekStartsOnMonday {
                // Convertir 1..7 (Dom..Sáb) a 0..6 (Lun..Dom) offset
                let mapped = (firstWeekday + 5) % 7 // Dom(1)->6, Lun(2)->0, ...
                return mapped
            } else {
                return firstWeekday - 1
            }
        }()

        let trailingEmptyCount: Int = {
            if weekStartsOnMonday {
                let mapped = (lastWeekday + 5) % 7
                return 6 - mapped
            } else {
                return 7 - lastWeekday
            }
        }()

        var grid: [Date] = []

        // Días del mes anterior para rellenar la primera semana
        if let start = date(byAdding: .day, value: -leadingEmptyCount, to: first) {
            for i in 0..<leadingEmptyCount {
                if let d = date(byAdding: .day, value: i, to: start) {
                    grid.append(d)
                }
            }
        }

        // Días del mes actual
        grid.append(contentsOf: monthDays)

        // Días del mes siguiente para completar la grilla
        if let after = date(byAdding: .day, value: 1, to: last) {
            for i in 0..<trailingEmptyCount {
                if let d = date(byAdding: .day, value: i, to: after) {
                    grid.append(d)
                }
            }
        }

        return grid
    }

    // Versión con locale para encabezado de días en español
    func shortWeekdaySymbolsShiftedToMonday(locale: Locale) -> [String] {
        var cal = self
        cal.locale = locale
        var symbols = cal.shortWeekdaySymbols
        // Mover Domingo al final para empezar en Lunes
        if let first = symbols.first {
            symbols.removeFirst()
            symbols.append(first)
        }
        // Capitalizar según idioma
        return symbols.map { $0.capitalized(with: locale) }
    }
}
