import SwiftUI

struct WatchNewTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var minutes = 5

    private let presets = [1, 3, 5, 10, 15, 20, 30, 45, 60]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Quick Timer")
                    .font(.headline)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(presets, id: \.self) { mins in
                        Button {
                            createTimer(minutes: mins)
                        } label: {
                            Text(formatMinutes(mins))
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                Text("Custom")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Minutes", selection: $minutes) {
                    ForEach(1..<121) { min in
                        Text("\(min) min").tag(min)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 80)

                Button("Start") {
                    createTimer(minutes: minutes)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("New Timer")
    }

    private func formatMinutes(_ mins: Int) -> String {
        if mins < 60 {
            return "\(mins)m"
        } else {
            return "1hr"
        }
    }

    private func createTimer(minutes: Int) {
        let timer = WatchTimer(
            name: "\(minutes) min timer",
            durationSeconds: minutes * 60
        )
        timer.start()
        modelContext.insert(timer)
        dismiss()
    }
}

#Preview {
    WatchNewTimerView()
        .modelContainer(for: WatchTimer.self, inMemory: true)
}
