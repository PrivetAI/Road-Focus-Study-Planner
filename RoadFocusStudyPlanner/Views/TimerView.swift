import SwiftUI

struct StudyTimerView: View {
    @EnvironmentObject var store: DataStore
    
    @State private var workMinutes = 25
    @State private var breakMinutes = 5
    @State private var timeRemaining: Int = 25 * 60
    @State private var isRunning = false
    @State private var isWorkPhase = true
    @State private var sessionCount = 0
    @State private var selectedSubject = ""
    @State private var timer: Timer?
    @State private var sessionStartTime: Date?
    
    let workOptions = [15, 25, 45, 60]
    let breakOptions = [5, 10, 15]
    
    var progress: Double {
        let total = Double(isWorkPhase ? workMinutes * 60 : breakMinutes * 60)
        guard total > 0 else { return 0 }
        return 1.0 - Double(timeRemaining) / total
    }
    
    var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Subject picker
                    if !store.subjects.isEmpty {
                        HStack {
                            Text("Studying:")
                                .foregroundColor(AppColors.darkGray)
                            Picker("Subject", selection: $selectedSubject) {
                                Text("General").tag("")
                                ForEach(store.subjects) { s in
                                    Text(s.name).tag(s.name)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(AppColors.gold)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Phase label
                    Text(isWorkPhase ? "WORK" : "BREAK")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isWorkPhase ? AppColors.gold : Color(red: 60/255, green: 179/255, blue: 113/255))
                        .tracking(4)
                    
                    // Circular timer
                    ZStack {
                        Circle()
                            .stroke(AppColors.lightGray, lineWidth: 12)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(
                                isWorkPhase ? AppColors.gold : Color(red: 60/255, green: 179/255, blue: 113/255),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.5), value: progress)
                        
                        VStack(spacing: 8) {
                            Text(timeString)
                                .font(.system(size: 48, weight: .thin, design: .monospaced))
                                .foregroundColor(AppColors.darkGray)
                            
                            Text("Sessions: \(sessionCount)")
                                .font(.caption)
                                .foregroundColor(AppColors.darkGray.opacity(0.6))
                        }
                    }
                    .frame(width: 240, height: 240)
                    .padding()
                    
                    // Controls
                    HStack(spacing: 24) {
                        Button(action: resetTimer) {
                            Text("Reset")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.darkGray)
                                .frame(width: 80, height: 44)
                                .background(AppColors.lightGray)
                                .cornerRadius(22)
                        }
                        
                        Button(action: toggleTimer) {
                            Text(isRunning ? "Pause" : "Start")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 50)
                                .background(AppColors.gold)
                                .cornerRadius(25)
                        }
                        
                        Button(action: skipPhase) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.darkGray)
                                .frame(width: 80, height: 44)
                                .background(AppColors.lightGray)
                                .cornerRadius(22)
                        }
                    }
                    
                    // Settings
                    VStack(spacing: 16) {
                        HStack {
                            Text("Work:")
                                .foregroundColor(AppColors.darkGray)
                            Spacer()
                            ForEach(workOptions, id: \.self) { m in
                                Button("\(m)m") {
                                    if !isRunning {
                                        workMinutes = m
                                        if isWorkPhase { timeRemaining = m * 60 }
                                    }
                                }
                                .font(.caption.bold())
                                .foregroundColor(workMinutes == m ? .white : AppColors.darkGray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(workMinutes == m ? AppColors.gold : AppColors.lightGray)
                                .cornerRadius(12)
                            }
                        }
                        
                        HStack {
                            Text("Break:")
                                .foregroundColor(AppColors.darkGray)
                            Spacer()
                            ForEach(breakOptions, id: \.self) { m in
                                Button("\(m)m") {
                                    if !isRunning {
                                        breakMinutes = m
                                        if !isWorkPhase { timeRemaining = m * 60 }
                                    }
                                }
                                .font(.caption.bold())
                                .foregroundColor(breakMinutes == m ? .white : AppColors.darkGray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(breakMinutes == m ? Color(red: 60/255, green: 179/255, blue: 113/255) : AppColors.lightGray)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .disabled(isRunning)
                    .opacity(isRunning ? 0.5 : 1)
                }
                .padding(.vertical)
            }
            .background(Color.white)
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func toggleTimer() {
        if isRunning {
            isRunning = false
            timer?.invalidate()
        } else {
            isRunning = true
            sessionStartTime = Date()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    onPhaseComplete()
                }
            }
        }
    }
    
    func resetTimer() {
        isRunning = false
        timer?.invalidate()
        isWorkPhase = true
        timeRemaining = workMinutes * 60
    }
    
    func skipPhase() {
        onPhaseComplete()
    }
    
    func onPhaseComplete() {
        timer?.invalidate()
        isRunning = false
        
        if isWorkPhase {
            // Record session
            let subj = selectedSubject.isEmpty ? "General" : selectedSubject
            store.timerSessions.append(TimerSession(
                date: Date(),
                durationMinutes: Double(workMinutes),
                subject: subj
            ))
            sessionCount += 1
            
            // Switch to break
            isWorkPhase = false
            timeRemaining = breakMinutes * 60
        } else {
            // Switch to work
            isWorkPhase = true
            timeRemaining = workMinutes * 60
        }
    }
}
