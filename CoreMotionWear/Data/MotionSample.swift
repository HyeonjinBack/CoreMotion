//
//  MotionSample.swift
//  CoreMotionWear
//
//  Created by 백현진 on 2/21/26.
//

import Foundation

struct MotionSample: Sendable {
    let timestamp: TimeInterval
    let roll: Double
    let pitch: Double
    let yaw: Double
    
    let rotX: Double
    let rotY: Double
    let rotZ: Double
    
    let accX: Double
    let accY: Double
    let accZ: Double
}

struct PostureBaseline: Codable, Sendable {
    let roll: Double
    let pitch: Double
    let yaw: Double
}

enum PostureState: String, Sendable {
    case unknown
    case good
    case warning // 임계치 근처
    case bad // 자세 무너짐 확정
}

enum PostureDirection: String, Sendable {
    case forward   // 거북목(고개 앞으로)
    case backward
    case leftTilt
    case rightTilt
    case leftTurn
    case rightTurn
    case none
}
