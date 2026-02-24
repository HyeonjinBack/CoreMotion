//
//  PostureDashboardView.swift
//  CoreMotionWear
//
//  Created by 백현진 on 2/21/26.
//

import SwiftUI

struct PostureDashboardView: View {
    @StateObject private var vm = PostureViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                statusCard
                
                controls
                
                liveCard
                
                Spacer()
            }
            .padding()
            .navigationTitle("w같다 아")
        }
        .onAppear {
            vm.motionService.refreshAvailability()
        }
    }
    
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("상태")
                .font(.headline)
            
            HStack {
                Text("모션 지원")
                Spacer()
                Text(vm.motionService.isAvailable ? "가능" : "불가")
                    .foregroundStyle(vm.motionService.isAvailable ? .green : .red)
            }
            
            HStack {
                Text("모니터링")
                Spacer()
                Text(vm.isMonitoring ? "ON" : "OFF")
            }
            
            Text(vm.statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button(vm.isMonitoring ? "Stop" : "Start") {
                    vm.isMonitoring ? vm.stopMonitoring() : vm.startMonitoring()
                }
                .buttonStyle(.borderedProminent)
                
                Button("바른 자세 캘리브레이션") {
                    vm.startCalibration(duration: 2.0)
                }
                .buttonStyle(.bordered)
                .disabled(!vm.isMonitoring)
            }
            
            if vm.calibrationProgress > 0 && vm.calibrationProgress < 1 {
                ProgressView(value: vm.calibrationProgress)
            }
            
            HStack {
                Text("경고 횟수")
                Spacer()
                Text("\(vm.warningsCount)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
    
    private var liveCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("실시간 자세")
                .font(.headline)
            
            HStack {
                Text("상태")
                Spacer()
                Text(vm.postureState.rawValue.uppercased())
            }
            HStack {
                Text("방향")
                Spacer()
                Text(vm.postureDirection.rawValue)
            }
            HStack {
                Text("Score(벗어남)")
                Spacer()
                Text(String(format: "%.3f", vm.score))
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Δroll: \(String(format: "%.3f", vm.deltaRoll))")
                Text("Δpitch: \(String(format: "%.3f", vm.deltaPitch))")
                Text("Δyaw: \(String(format: "%.3f", vm.deltaYaw))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
