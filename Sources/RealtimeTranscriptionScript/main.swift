import Foundation
import AVFoundation
import Starscream
import CoreMedia

class RealtimeTranscription: NSObject, WebSocketDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    private var socket: WebSocket?
    private let apiKey: String
    private let websocketURL = "wss://api.assemblyai.com/v2/realtime/ws?sample_rate=16000"
    private var isRunning = false
    private var captureSession: AVCaptureSession?
    private var audioOutput: AVCaptureAudioDataOutput?
    
    init(apiKey: String) {
        self.apiKey = apiKey
        super.init()
    }
    
    func start() {
        setupWebSocket()
        setupAudioCapture()
        startAudioCapture()
        isRunning = true
        
        // Keep the script running
        while isRunning {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
        }
    }
    
    private func setupWebSocket() {
        var request = URLRequest(url: URL(string: websocketURL)!)
        request.timeoutInterval = 5
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    private func setupAudioCapture() {
        captureSession = AVCaptureSession()
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("No audio device found")
            return
        }
        
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if captureSession!.canAddInput(audioInput) {
                captureSession!.addInput(audioInput)
            }
            
            audioOutput = AVCaptureAudioDataOutput()
            if captureSession!.canAddOutput(audioOutput!) {
                captureSession!.addOutput(audioOutput!)
            }
            
            // Set the audio settings to match AssemblyAI requirements
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 16000.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false
            ]
            audioOutput?.audioSettings = audioSettings
            
            let queue = DispatchQueue(label: "audioQueue")
            audioOutput?.setSampleBufferDelegate(self, queue: queue)
        } catch {
            print("Error setting up audio capture: \(error)")
        }
    }
    
    private func startAudioCapture() {
        captureSession?.startRunning()
    }
    
    private func convertBufferToData(_ sampleBuffer: CMSampleBuffer) -> Data? {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return nil
        }
        
        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        let status = CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &dataPointer)
        
        guard status == noErr, let dataPointer = dataPointer else {
            return nil
        }
        
        return Data(bytes: dataPointer, count: length)
    }
    
    // MARK: - WebSocketDelegate methods
    
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(_):
            print("WebSocket connected")
        case .text(let string):
            if let data = string.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let text = json["text"] as? String {
                print("Transcription: \(text)")
            }
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        case .disconnected(_, _):
            print("WebSocket disconnected")
            isRunning = false
        default:
            break
        }
    }
    
    // MARK: - AVCaptureAudioDataOutputSampleBufferDelegate method
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let data = convertBufferToData(sampleBuffer) else {
            print("Failed to convert sample buffer to data")
            return
        }
        
        // Send the raw PCM data directly
        socket?.write(data: data)
    }
}

// Run the script
let apiKey = "your_assemblyai_api_key_here"
let transcription = RealtimeTranscription(apiKey: apiKey)
transcription.start()
