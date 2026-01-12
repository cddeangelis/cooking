import SwiftUI
import WatchKit

struct WatchTimerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var timer: WatchTimer

    @State private var displayTime = ""
    let timerUpdate = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            Text(timer.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(
                        timer.isComplete ? Color.green : Color.accentColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timer.progress)

                Text(displayTime)
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(timer.isComplete ? .green : .primary)
            }
            .padding(.horizontal)

            HStack(spacing: 20) {
                if timer.isComplete {
                    Button {
                        timer.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                } else if timer.isRunning {
                    Button {
                        timer.pause()
                        WKInterfaceDevice.current().play(.click)
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                } else {
                    Button {
                        timer.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        timer.start()
                        WKInterfaceDevice.current().play(.start)
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onReceive(timerUpdate) { _ in
            timer.updateRemaining()
            displayTime = timer.formattedRemaining

            if timer.isComplete && timer.isRunning {
                timer.isRunning = false
                WKInterfaceDevice.current().play(.notification)
            }
        }
        .onAppear {
            displayTime = timer.formattedRemaining
        }
    }
}

#Preview {
    let timer = WatchTimer(name: "Boil Pasta", durationSeconds: 600)
    return WatchTimerDetailView(timer: timer)
        .modelContainer(for: WatchTimer.self, inMemory: true)
}
