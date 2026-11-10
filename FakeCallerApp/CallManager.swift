import CallKit
import AVFoundation

final class CallManager: NSObject, CXProviderDelegate {
    static let shared = CallManager()
    
    private let provider: CXProvider
    private var currentCallUUID: UUID?
    private var audioPlayer: AVAudioPlayer?
    
    private override init() {
        let config = CXProviderConfiguration()
        config.supportsVideo = false
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.generic, .phoneNumber]
        config.includesCallsInRecents = true
        // Optional: add a ringtone file named "ringtone.caf" to your project
        // config.ringtoneSound = "ringtone.caf"
        
        provider = CXProvider(configuration: config)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    func triggerFakeCall(name: String, number: String? = nil) {
        let uuid = UUID()
        currentCallUUID = uuid
        
        let update = CXCallUpdate()
        update.localizedCallerName = name
        update.hasVideo = false
        
        if let number, !number.isEmpty {
            update.remoteHandle = CXHandle(type: .phoneNumber, value: number)
        } else {
            update.remoteHandle = CXHandle(type: .generic, value: name)
        }
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error {
                print("Failed to report call: \(error.localizedDescription)")
            } else {
                print("Fake call reported successfully")
            }
        }
    }
    
    // MARK: - CXProviderDelegate
    func providerDidReset(_ provider: CXProvider) {
        currentCallUUID = nil
        stopAudio()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        configureAudioSession()
        playOptionalVoiceClip()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        stopAudio()
        action.fulfill()
        currentCallUUID = nil
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // Audio session is ready
    }
    
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth])
        try? session.setActive(true)
    }
    
    private func playOptionalVoiceClip() {
        // Optional: add an audio file named "voice.m4a" to the project
        guard let url = Bundle.main.url(forResource: "voice", withExtension: "m4a") else { return }
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
