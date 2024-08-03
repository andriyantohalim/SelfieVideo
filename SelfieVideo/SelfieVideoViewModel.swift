//
//  VideoRecorder.swift
//  SelfieVideo
//
//  Created by Andriyanto Halim on 3/8/24.
//

import AVFoundation
import Photos

class SelfieVideoViewModel: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    private var captureSession: AVCaptureSession?
    private var movieOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var outputURL: URL?

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession?.addInput(input)
        } catch {
            print("Error setting up camera input: \(error)")
        }

        movieOutput = AVCaptureMovieFileOutput()
        if let movieOutput = movieOutput {
            captureSession?.addOutput(movieOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func startRecording() {
        guard let movieOutput = movieOutput else { return }
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".mov"
        outputURL = tempDir.appendingPathComponent(fileName)
        movieOutput.startRecording(to: outputURL!, recordingDelegate: self)
    }

    func stopRecording() {
        movieOutput?.stopRecording()
    }

    private func saveToPhotoLibrary() {
        guard let outputURL = outputURL else { return }
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                }) { success, error in
                    if let error = error {
                        print("Error saving video: \(error)")
                    }
                }
            }
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error)")
        } else {
            saveToPhotoLibrary()
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
}
