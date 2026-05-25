import SwiftUI
import Speech
import AVFoundation

struct VoiceInputButton: View {
    @Binding var text: String
    @State private var isRecording = false
    @State private var permissionDenied = false
    @State private var recognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var request: SFSpeechAudioBufferRecognitionRequest?

    var body: some View {
        Button {
            if isRecording {
                stopRecording()
            } else {
                Task { await startRecording() }
            }
        } label: {
            Image(systemName: isRecording ? "mic.fill" : "mic")
                .font(.system(size: 22))
                .foregroundColor(isRecording ? .red : .white.opacity(0.6))
                .frame(width: 36, height: 36)
                .background(isRecording ? Color.red.opacity(0.15) : Color.clear)
                .cornerRadius(18)
                .animation(.easeInOut(duration: 0.2), value: isRecording)
        }
        .alert("Microphone Access Denied", isPresented: $permissionDenied) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow microphone access in Settings to use voice input.")
        }
    }

    // MARK: - Recording

    @MainActor
    private func startRecording() async {
        // Check speech permission
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard status == .authorized else { permissionDenied = true; return }

        // Check mic permission
        let micStatus = await AVAudioApplication.requestRecordPermission()
        guard micStatus else { permissionDenied = true; return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            let req = SFSpeechAudioBufferRecognitionRequest()
            req.shouldReportPartialResults = true
            self.request = req

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                req.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true

            recognitionTask = recognizer?.recognitionTask(with: req) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.text = result.bestTranscription.formattedString
                    }
                }
                if error != nil || result?.isFinal == true {
                    DispatchQueue.main.async { self.stopRecording() }
                }
            }
        } catch {
            isRecording = false
        }
    }

    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
