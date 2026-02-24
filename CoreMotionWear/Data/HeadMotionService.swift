//
//  HeadMotionService.swift
//  CoreMotionWear
//
//  Created by 백현진 on 2/21/26.
//

import Foundation
import CoreMotion
import Combine

@MainActor
final class HeadMotionService: ObservableObject {
    private let manager = CMHeadphoneMotionManager()
    private let queue = OperationQueue()
    
    @Published private(set) var isAvailable: Bool = false
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var lastErrorMessage: String? = nil
    
    var onSample: ((MotionSample) -> Void)?
    
    init() {
        queue.name = "HeadphoneMotionService.queue"
        queue.qualityOfService = .userInteractive
        refreshAvailability()
    }
    
    func refreshAvailability() {
        isAvailable = manager.isDeviceMotionAvailable
    }
    
    func start() {
        refreshAvailability()
        
        guard isAvailable else {
            lastErrorMessage = "헤드폰 모션이 지원되지 않거나 AirPods가 연결/착용되지 않았습니다"
            return
        }

        guard !isRunning else { return }
        
        lastErrorMessage = nil
        isRunning = true
        
        manager.startDeviceMotionUpdates(to: queue) { [weak self] motion, error in
            guard let self else { return }
            if let error {
                Task { @MainActor in
                    self.lastErrorMessage = error.localizedDescription
                    self.isRunning = false
                }
                return
            }
            
            guard let motion else { return }
            
            let s = MotionSample(timestamp: Date().timeIntervalSince1970, roll: motion.attitude.roll, pitch: motion.attitude.pitch, yaw: motion.attitude.yaw, rotX: motion.rotationRate.x, rotY: motion.rotationRate.y, rotZ: motion.rotationRate.z, accX: motion.userAcceleration.x, accY: motion.userAcceleration.y, accZ: motion.userAcceleration.z)
        
            Task { @MainActor in
                self.onSample?(s)
            }
        }
    }
    
    func stop() {
        guard isRunning else { return }
        manager.stopDeviceMotionUpdates()
        isRunning = false
    }
}
