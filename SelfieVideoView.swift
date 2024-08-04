//
//  SelfieVideoView.swift
//  SelfieVideo
//
//  Created by Andriyanto Halim on 3/8/24.
//

import SwiftUI
import AVFoundation

struct SelfieVideoView: View {
    @ObservedObject var viewModel = SelfieVideoViewModel()
    @State private var isRecording = false
    
    var body: some View {
        ZStack {
            SelfieVideoViewPreview(previewLayer: viewModel.getPreviewLayer())
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                Button(action: {
                    if isRecording {
                        viewModel.stopRecording()
                    } else {
                        viewModel.startRecording()
                    }
                    isRecording.toggle()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .fill(isRecording ? Color.white : Color.red)
                                .stroke(Color.gray, lineWidth: 2)
                                .frame(width: 60, height: 60)
                        )
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct SelfieVideoViewPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        if let previewLayer = previewLayer {
            previewLayer.frame = UIScreen.main.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}


#Preview {
    SelfieVideoView()
}
