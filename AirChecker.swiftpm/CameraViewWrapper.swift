//
//  CameraViewWrapper.swift
//  AirChecker
//
//  Created by Baiyi Zhang on 2/22/24.
//

import Foundation
import SwiftUI
import AVFoundation
import Vision


struct CameraViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let cvc = CameraViewController()
        return cvc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
