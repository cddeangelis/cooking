import SwiftUI
import SwiftData

struct WatchContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WatchTimer.createdAt, order: .reverse) private var timers: [WatchTimer]

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
                WatchNewTimerView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "timer")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No Timers")
                .font(.headline)

            Button("Add Timer") {
                showingNewTimer = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var timerList: some View {
        List {
            ForEach(timers) { timer in
                NavigationLink {
                    WatchTimerDetailView(timer: timer)
                } label: {
                    WatchTimerRowView(timer: timer)
                }
            }
            .onDelete(perform: deleteTimers)
        }
    }

    private func deleteTimers(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(timers[index])
        }
    }
}

struct WatchTimerRowView: View {
    @Bindable var timer: WatchTimer

    @State private var displayTime = ""
    let timerUpdate = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timer.name)
                .font(.headline)
                .lineLimit(1)

            HStack {
                Text(displayTime)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(timer.isComplete ? .green : .primary)

                Spacer()

                if timer.isRunning {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                } else if timer.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
            }
        }
        .onReceive(timerUpdate) { _ in
            timer.updateRemaining()
            displayTime = timer.formattedRemaining
        }
        .onAppear {
            displayTime = timer.formattedRemaining
        }
    }
}

#Preview {
    WatchContentView()
        .modelContainer(for: WatchTimer.self, inMemory: true)
}
