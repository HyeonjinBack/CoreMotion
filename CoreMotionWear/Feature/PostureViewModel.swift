//
//  PostureViewModel.swift
//  CoreMotionWear
//
//  Created by 백현진 on 2/21/26.
//

import Combine
import SwiftUI
import AudioToolbox

@MainActor
final class PostureViewModel: ObservableObject {
    @Published var postureState: PostureState = .unknown
    @Published var postureDirection: PostureDirection = .none
    @Published var score: Double = 0
    
    @Published var deltaRoll: Double = 0
    @Published var deltaPitch: Double = 0
    @Published var deltaYaw: Double = 0
    
    @Published var isMonitoring: Bool = false
    @Published var isRecording: Bool = false
    
    @Published var statusText: String = "대기 중"
    @Published var calibrationProgress: Double = 0
    
    @Published var warningsCount: Int = 0
    
    let motionService = HeadMotionService()
    private let analyzer = PostureAnalyzer()
    
    private var calibSamples: [MotionSample] = []
    private var isCalibrating: Bool = false
    private var calibStartTime: TimeInterval = 0
    private var calibDuration: Double = 2.0
    
    private var lastAlertTime: TimeInterval = 0
    private var alertCooldown: Double = 30 // 30초에 한 번만 경고
    
    init() {
        motionService.onSample = { [weak self] sample in
            self?.handle(sample)
        }
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        statusText = "모션 시작 중..."
        motionService.start()
        isMonitoring = motionService.isRunning
        if isMonitoring {
            statusText = "모니터링 중"
        } else if let msg = motionService.lastErrorMessage {
            statusText = msg
        } else {
            statusText = "모션 시작 실패"
        }
    }
    
    func stopMonitoring() {
        motionService.stop()
        isMonitoring = false
        postureState = .unknown
        statusText = "중지됨"
        calibrationProgress = 0
        isCalibrating = false
        calibSamples.removeAll()
    }
    
    func startCalibration(duration: Double = 2.0) {
        guard isMonitoring else {
            statusText = "먼저 모니터리을 시작하세요!"
            return
        }
        calibDuration = max(1.0, duration)
        calibSamples.removeAll()
        isCalibrating = true
        calibStartTime = Date().timeIntervalSince1970
        calibrationProgress = 0
        statusText = "바른 자세 유지.. 캘리브레이션 중"
    }
    
    private func finishCalibration() async {
        guard !calibSamples.isEmpty else {
            statusText = "캘리브레이션 샘플이 부족합니다."
            isCalibrating = false
            return
        }
        let avgRoll = calibSamples.map(\.roll).reduce(0, +) / Double(calibSamples.count)
        let avgPitch = calibSamples.map(\.pitch).reduce(0, +) / Double(calibSamples.count)
        let avgYaw = calibSamples.map(\.yaw).reduce(0, +) / Double(calibSamples.count)
        
        await analyzer.setBaseline(PostureBaseline(roll: avgRoll, pitch: avgPitch, yaw: avgYaw))
        
        isCalibrating = false
        calibrationProgress = 1
        statusText = "캘리브레이션 완료!!"
        postureState = .good
    }
    
    private func handle(_ sample: MotionSample) {
        if isCalibrating {
            calibSamples.append(sample)
            let elapsed = sample.timestamp - calibStartTime
            calibrationProgress = min(1, elapsed / calibDuration)
            if elapsed >= calibDuration {
                Task { await finishCalibration() }
            }
            return
        }
        
        Task {
            let result = await analyzer.process(sample)
            await MainActor.run {
                postureState = result.state
                postureDirection = result.direction
                score = result.score
                deltaRoll = result.deltaRoll
                deltaPitch = result.deltaPitch
                deltaYaw = result.deltaYaw
                
                // 경고 카운트/쿨다운
                if result.state == .bad {
                    maybeAlert(now: sample.timestamp, direction: result.direction)
                }
            }
        }
    }
    
    private func maybeAlert(now: TimeInterval, direction: PostureDirection) {
        guard now - lastAlertTime >= alertCooldown else { return }
        lastAlertTime = now
        warningsCount += 1
        
        // 여기 고쳐야함
        AudioServicesPlaySystemSound(1005)
        statusText = "자세 교정 필요: \(direction.rawValue)"
    }    
}
