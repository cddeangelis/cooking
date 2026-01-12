import SwiftUI
import SwiftData
import UserNotifications

struct TimerListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CookingTimer.createdAt, order: .reverse) private var timers: [CookingTimer]

    @State private var showingNewTimer = false

    var body: some View {
        NavigationStack {
            Group {
                if timers.isEmpty {
                    emptyState
                } else {
                    timerList
                }
            }
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewTimer = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewTimer) {
                NewTimerSheet()
            }
        }
        .onAppear {
            requestNotificationPermission()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Timers", systemImage: "timer")
        } description: {
            Text("Start a timer while cooking or add one manually")
        } actions: {
            Button("Add Timer") {
                showingNewTimer = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var timerList: some View {
        List {
            Section("Active") {
                let active = timers.filter { $0.isRunning || (!$0.isComplete && !$0.isRunning) }
                if active.isEmpty {
                    Text("No active timers")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(active) { timer in
                        TimerRowView(timer: timer)
                    }
                    .onDelete { indexSet in
                        deleteTimers(active, at: indexSet)
                    }
                }
            }

            Section("Completed") {
                let completed = timers.filter { $0.isComplete }
                if completed.isEmpty {
                    Text("No completed timers")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(completed) { timer in
                        TimerRowView(timer: timer)
                    }
                    .onDelete { indexSet in
                        deleteTimers(completed, at: indexSet)
                    }
                }
            }

            Section {
                Button("Clear All Completed", role: .destructive) {
                    let completed = timers.filter { $0.isComplete }
                    for timer in completed {
                        modelContext.delete(timer)
                    }
                }
                .disabled(timers.filter { $0.isComplete }.isEmpty)
            }
        }
    }

    private func deleteTimers(_ list: [CookingTimer], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(list[index])
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}

struct TimerRowView: View {
    @Bindable var timer: CookingTimer
    @Environment(\.modelContext) private var modelContext

    @State private var displayTime: String = ""
    let timerUpdate = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(timer.name)
                    .font(.headline)

                Text(displayTime)
                    .font(.system(.title2, design: .monospaced))
                    .foregroundStyle(timer.isComplete ? .green : .primary)
            }

            Spacer()

            HStack(spacing: 12) {
                if timer.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                } else if timer.isRunning {
                    Button {
                        timer.pause()
                        cancelNotification(for: timer)
                    } label: {
                        Image(systemName: "pause.circle.fill")
                            .font(.title2)
                    }
                } else {
                    Button {
                        timer.start()
                        scheduleNotification(for: timer)
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
                }

                Button {
                    timer.reset()
                    cancelNotification(for: timer)
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .onReceive(timerUpdate) { _ in
            timer.updateRemaining()
            displayTime = timer.formattedRemaining

            if timer.isComplete && timer.isRunning {
                timer.isRunning = false
            }
        }
        .onAppear {
            displayTime = timer.formattedRemaining
        }
    }

    private func scheduleNotification(for timer: CookingTimer) {
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete!"
        content.body = "\(timer.name) is done"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(timer.remainingSeconds),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: timer.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func cancelNotification(for timer: CookingTimer) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [timer.id.uuidString]
        )
    }
}

struct NewTimerSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = "Timer"
    @State private var hours = 0
    @State private var minutes = 5
    @State private var seconds = 0

    var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Timer Name") {
                    TextField("Name", text: $name)
                }

                Section("Duration") {
                    HStack {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24) { Text("\($0) hr").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60) { Text("\($0) min").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)

                        Picker("Seconds", selection: $seconds) {
                            ForEach(0..<60) { Text("\($0) sec").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 150)
                }

                Section("Quick Presets") {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(TimerPreset.common) { preset in
                            Button {
                                applyPreset(preset)
                            } label: {
                                Text(preset.formattedDuration)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("New Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        createAndStartTimer()
                    }
                    .disabled(totalSeconds == 0)
                }
            }
        }
    }

    private func applyPreset(_ preset: TimerPreset) {
        hours = preset.seconds / 3600
        minutes = (preset.seconds % 3600) / 60
        seconds = preset.seconds % 60
        name = preset.name
    }

    private func createAndStartTimer() {
        let timer = CookingTimer(
            name: name.isEmpty ? "Timer" : name,
            durationSeconds: totalSeconds
        )
        timer.start()
        modelContext.insert(timer)
        dismiss()
    }
}

#Preview {
    TimerListView()
        .modelContainer(for: CookingTimer.self, inMemory: true)
}
