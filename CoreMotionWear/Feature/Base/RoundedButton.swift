//
//  RoundedButton.swift
//  CoreMotionWear
//
//  Created by 백현진 on 3/13/26.
//

import SwiftUI

struct RoundedButton: View {
    @State private var isRotated: Bool = false
    
    var title: String?
    var font: Font?
    var imageName: String?
    var foregroundColor: Color?
    var backgroundColor: Color?
    var rotatingAnimation: Bool = false

    var action: (() -> Void)
    
    var body: some View {
        Button {
            action()
            if rotatingAnimation {
                isRotated.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                if let title {
                    Text(title)
                        .font(font)
                        .tint(foregroundColor ?? .black)
                }
                
                if let imageName {
                    Image(systemName: imageName)
                        .font(font)
                        .tint(foregroundColor ?? .black)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(width: title != nil ? nil : 24, height: title != nil ? nil : 24)
            .background(Capsule().fill(backgroundColor ?? .white))
            .rotation3DEffect(
                .degrees(isRotated ? 360 : 0),
                axis: (x: 0, y: 1, z: 0) // Y축 기준 회전
            )
            .animation(.smooth, value: isRotated)
        }
    }
}

#Preview {
    RoundedButton(title: "example", font: .title, imageName: "heart.fill", foregroundColor: .white, backgroundColor: .blue, rotatingAnimation: true, action: {})
}
