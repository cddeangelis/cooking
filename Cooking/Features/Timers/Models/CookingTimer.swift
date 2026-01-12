import Foundation
import SwiftData

@Model
final class CookingTimer {
    var id: UUID
    var name: String
    var durationSeconds: Int
    var remainingSeconds: Int
    var isRunning: Bool
    var startedAt: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String = "Timer",
        durationSeconds: Int = 300,
        remainingSeconds: Int? = nil,
        isRunning: Bool = false,
        startedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.durationSeconds = durationSeconds
        self.remainingSeconds = remainingSeconds ?? durationSeconds
        self.isRunning = isRunning
        self.startedAt = startedAt
        self.createdAt = createdAt
    }

    var formattedDuration: String {
        formatTime(durationSeconds)
    }

    var formattedRemaining: String {
        formatTime(remainingSeconds)
    }

    var progress: Double {
        guard durationSeconds > 0 else { return 0 }
        return Double(durationSeconds - remainingSeconds) / Double(durationSeconds)
    }

    var isComplete: Bool {
        remainingSeconds <= 0
    }

    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }

    func start() {
        isRunning = true
        startedAt = Date()
    }

    func pause() {
        if isRunning, let started = startedAt {
            let elapsed = Int(Date().timeIntervalSince(started))
            remainingSeconds = max(0, remainingSeconds - elapsed)
        }
        isRunning = false
        startedAt = nil
    }

    func reset() {
        isRunning = false
        startedAt = nil
        remainingSeconds = durationSeconds
    }

    func updateRemaining() {
        guard isRunning, let started = startedAt else { return }
        let elapsed = Int(Date().timeIntervalSince(started))
        remainingSeconds = max(0, durationSeconds - elapsed)
    }
}

struct TimerPreset: Identifiable {
    let id = UUID()
    let name: String
    let seconds: Int

    var formattedDuration: String {
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(remainingMinutes) min"
            }
        }
    }

    static let common: [TimerPreset] = [
        TimerPreset(name: "1 Minute", seconds: 60),
        TimerPreset(name: "3 Minutes", seconds: 180),
        TimerPreset(name: "5 Minutes", seconds: 300),
        TimerPreset(name: "10 Minutes", seconds: 600),
        TimerPreset(name: "15 Minutes", seconds: 900),
        TimerPreset(name: "20 Minutes", seconds: 1200),
        TimerPreset(name: "30 Minutes", seconds: 1800),
        TimerPreset(name: "45 Minutes", seconds: 2700),
        TimerPreset(name: "1 Hour", seconds: 3600)
    ]
}
