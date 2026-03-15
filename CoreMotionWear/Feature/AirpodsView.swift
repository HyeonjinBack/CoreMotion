//
//  AirpodsView.swift
//  CoreMotionWear
//
//  Created by 백현진 on 3/14/26.
//

import SwiftUI

struct AirpodsView: View {
    @State private var checkAirpods: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            if checkAirpods {
                Image(systemName: "checkmark")
                   .font(.largeTitle)
                   .foregroundStyle(.green)
                   .symbolEffect(.bounce, options: .nonRepeating, isActive: checkAirpods)
            } else {
                Image(systemName: "airpods.pro")
                    .font(.largeTitle)
                    .symbolEffect(.bounce, options: .speed(0.5))
            }

            HStack {
                Text("1. 에어팟을 착용해주세요")
        
                Button {
                    checkAirpods.toggle()
                } label: {
                    Text("tap")
                }
            }
    
        }
    }
}

#Preview {
    AirpodsView()
}
