//
//  PostureAnalyzer.swift
//  CoreMotionWear
//
//  Created by 백현진 on 2/21/26.
//

import Foundation

struct PostureConfig: Sendable {
    // rad 기준 (0.17rad = 10)
    var enterBad: Double = 0.17
    var exitBad: Double = 0.12
    
    var enterWarn: Double = 0.12
    var exitWarn: Double = 0.08
    
    //지속시간(초)
    var badHoldSeconds: Double = 1.2
    
    // EMA(0~1), 값이 클 수록 최근 값 믿음
    var emaAlpha: Double = 0.25
    
    // 큰 움직임(자리 이동) 시 무시 (가속도 크기)
    var moveIgnoreAccMagnitude: Double = 0.25
}

struct PostureResult: Sendable {
    var state: PostureState
    var direction: PostureDirection
    var deltaRoll: Double
    var deltaPitch: Double
    var deltaYaw: Double
    var score: Double // 현재 벗어난 정도(최대 값)
}

actor PostureAnalyzer {
    private var baseline: PostureBaseline?
    private var config: PostureConfig
    
    // EMA 스무딩된 델타
    private var emaRoll: Double = 0
    private var emaPitch: Double = 0
    private var emaYaw: Double = 0
    private var hasEMA: Bool = false
    
    // hold 체크
    private var badSince: TimeInterval? = nil
    
    // 히스테리시스 상태 추적
    private var lastState: PostureState = .unknown
    
    init(config: PostureConfig = .init()) {
        self.config = config
    }
    
    func setBaseline(_ b: PostureBaseline) {
        baseline = b
        // baseline 변경 시 EMA/상태 초기화
        hasEMA = false
        emaRoll = 0; emaPitch = 0; emaYaw = 0
        badSince = nil
        lastState = .good
    }
    
    func updateConfig(_ newConfig: PostureConfig) {
        config = newConfig
    }
    
    func process(_ sample: MotionSample) -> PostureResult {
        guard let baseline else {
            return PostureResult(state: .unknown, direction: .none,
                                deltaRoll: 0, deltaPitch: 0, deltaYaw: 0, score: 0)
        }
        
        // 자리 이동(큰 움직임) 감지 시: 판정 유예(오탐 방지)
        let accMag = sqrt(sample.accX*sample.accX + sample.accY*sample.accY + sample.accZ*sample.accZ)
        if accMag > config.moveIgnoreAccMagnitude {
            badSince = nil
            lastState = .unknown
            return PostureResult(state: .unknown, direction: .none,
                                deltaRoll: emaRoll, deltaPitch: emaPitch, deltaYaw: emaYaw, score: 0)
        }
        
        let dRoll = sample.roll - baseline.roll
        let dPitch = sample.pitch - baseline.pitch
        let dYaw = sample.yaw - baseline.yaw
        
        // EMA
        if !hasEMA {
            emaRoll = dRoll; emaPitch = dPitch; emaYaw = dYaw
            hasEMA = true
        } else {
            let a = config.emaAlpha
            emaRoll = a * dRoll + (1 - a) * emaRoll
            emaPitch = a * dPitch + (1 - a) * emaPitch
            emaYaw = a * dYaw + (1 - a) * emaYaw
        }
        
        let absR = abs(emaRoll), absP = abs(emaPitch), absY = abs(emaYaw)
        let score = max(absR, absP, absY)
        let direction = inferDirection(r: emaRoll, p: emaPitch, y: emaYaw)
        
        // 히스테리시스: 상태별 임계값 다르게
        switch lastState {
        case .bad:
            // bad에서 빠져나오려면 exitBad 이하
            if score <= config.exitBad {
                badSince = nil
                lastState = .warning // 바로 good로 보내면 흔들림 → warning 거치기
            }
        case .warning:
            // warning → bad 진입
            if score >= config.enterBad {
                // hold 시작/유지
                if badSince == nil { badSince = sample.timestamp }
                if let badSince, (sample.timestamp - badSince) >= config.badHoldSeconds {
                    lastState = .bad
                }
            } else if score <= config.exitWarn {
                badSince = nil
                lastState = .good
            } else {
                badSince = nil // warning 유지 중인데 bad 조건이 아니면 hold 리셋
            }
        case .good, .unknown:
            if score >= config.enterWarn {
                lastState = .warning
            } else {
                lastState = .good
            }
        }
        
        // good/unknown에서는 badSince 정리
        if lastState != .warning { badSince = nil }
        
        return PostureResult(
            state: lastState,
            direction: direction,
            deltaRoll: emaRoll,
            deltaPitch: emaPitch,
            deltaYaw: emaYaw,
            score: score
        )
    }
    
    private func inferDirection(r: Double, p: Double, y: Double) -> PostureDirection {
        // 가장 크게 벗어난 축 기준으로 방향 추정
        let absR = abs(r), absP = abs(p), absY = abs(y)
        if absP >= absR && absP >= absY {
            // pitch: 보통 +/-(기기 좌표계에 따라 다를 수 있음) → 실제 테스트 후 방향 반전 필요할 수 있음
            return p > 0 ? .forward : .backward
        } else if absR >= absP && absR >= absY {
            return r > 0 ? .rightTilt : .leftTilt
        } else {
            return y > 0 ? .rightTurn : .leftTurn
        }
    }
}
