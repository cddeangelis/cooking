import SwiftUI
import AVFoundation

struct CookModeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let recipe: Recipe
    let servingMultiplier: Double

    @State private var currentStepIndex = 0
    @State private var activeTimers: [CookingTimer] = []
    @State private var showingTimerSheet = false

    private var sortedInstructions: [Instruction] {
        recipe.instructions.sorted { $0.stepNumber < $1.stepNumber }
    }

    private var currentInstruction: Instruction? {
        guard currentStepIndex < sortedInstructions.count else { return nil }
        return sortedInstructions[currentStepIndex]
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    progressBar

                    TabView(selection: $currentStepIndex) {
                        ForEach(Array(sortedInstructions.enumerated()), id: \.element.id) { index, instruction in
                            StepView(
                                instruction: instruction,
                                stepNumber: index + 1,
                                totalSteps: sortedInstructions.count,
                                onStartTimer: { minutes in
                                    startTimer(name: "Step \(index + 1)", minutes: minutes)
                                }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    navigationButtons
                    activeTimersBar
                }
            }
            .navigationTitle(recipe.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingTimerSheet = true
                    } label: {
                        Image(systemName: "timer")
                    }
                }
            }
            .sheet(isPresented: $showingTimerSheet) {
                TimerListView()
                    .presentationDetents([.medium, .large])
            }
            .persistentSystemOverlays(.hidden)
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            let progress = CGFloat(currentStepIndex + 1) / CGFloat(sortedInstructions.count)
            Rectangle()
                .fill(Color.accentColor)
                .frame(width: geometry.size.width * progress)
        }
        .frame(height: 4)
        .background(Color.secondary.opacity(0.2))
    }

    private var navigationButtons: some View {
        HStack(spacing: 40) {
            Button {
                withAnimation {
                    if currentStepIndex > 0 {
                        currentStepIndex -= 1
                    }
                }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 50))
            }
            .disabled(currentStepIndex == 0)

            Text("\(currentStepIndex + 1) of \(sortedInstructions.count)")
                .font(.headline)
                .foregroundStyle(.secondary)

            Button {
                withAnimation {
                    if currentStepIndex < sortedInstructions.count - 1 {
                        currentStepIndex += 1
                    }
                }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 50))
            }
            .disabled(currentStepIndex == sortedInstructions.count - 1)
        }
        .padding(.vertical, 20)
    }

    @ViewBuilder
    private var activeTimersBar: some View {
        if !activeTimers.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(activeTimers) { timer in
                        ActiveTimerPill(timer: timer)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 50)
            .background(Color.secondary.opacity(0.1))
        }
    }

    private func startTimer(name: String, minutes: Int) {
        let timer = CookingTimer(name: name, durationSeconds: minutes * 60)
        timer.start()
        modelContext.insert(timer)
        activeTimers.append(timer)
    }
}

struct StepView: View {
    let instruction: Instruction
    let stepNumber: Int
    let totalSteps: Int
    let onStartTimer: (Int) -> Void

    @State private var isSpeaking = false
    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Step \(stepNumber)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            Text(instruction.text)
                .font(.title)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let timerMinutes = instruction.timerMinutes {
                Button {
                    onStartTimer(timerMinutes)
                } label: {
                    Label("Start \(timerMinutes) min timer", systemImage: "timer")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            Button {
                speakStep()
            } label: {
                Image(systemName: isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2")
                    .font(.title2)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func speakStep() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            let utterance = AVSpeechUtterance(string: "Step \(stepNumber). \(instruction.text)")
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            synthesizer.speak(utterance)
            isSpeaking = true
        }
    }
}

struct ActiveTimerPill: View {
    @Bindable var timer: CookingTimer
    @State private var displayTime: String = ""

    let timerUpdate = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
            Text(timer.name)
                .fontWeight(.medium)
            Text(displayTime)
                .monospacedDigit()
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(timer.isComplete ? Color.green : Color.accentColor)
        .foregroundStyle(.white)
        .clipShape(Capsule())
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
    CookModeView(
        recipe: Recipe(
            title: "Test Recipe",
            instructions: [
                Instruction(stepNumber: 1, text: "First step of the recipe", timerMinutes: 5),
                Instruction(stepNumber: 2, text: "Second step of the recipe"),
                Instruction(stepNumber: 3, text: "Third and final step", timerMinutes: 10)
            ]
        ),
        servingMultiplier: 1.0
    )
    .modelContainer(for: CookingTimer.self, inMemory: true)
}
