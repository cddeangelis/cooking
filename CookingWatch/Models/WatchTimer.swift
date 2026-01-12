import Foundation
import SwiftData

@Model
final class WatchTimer {
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

    var formattedRemaining: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let secs = remainingSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }

    var progress: Double {
        guard durationSeconds > 0 else { return 0 }
        return Double(durationSeconds - remainingSeconds) / Double(durationSeconds)
    }

    var isComplete: Bool {
        remainingSeconds <= 0
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
