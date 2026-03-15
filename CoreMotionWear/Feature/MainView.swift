//
//  MainView.swift
//  CoreMotionWear
//
//  Created by 백현진 on 2/24/26.
//

import SwiftUI

struct MainView: View {
    @State private var showPostureSetting = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapView()
                    .edgesIgnoringSafeArea(.bottom)
        
                VStack {
                    Spacer()
                    HStack(spacing: 24) {
                        Group {
                            Button {
                                
                            } label: {
                                ZStack {
                                    Circle()
                                    
                                    Image(systemName: "gear")
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .padding()
                                }
                                .frame(width: 80, height: 80)
                            }
                            
                            Button {
                                
                            } label: {
                                ZStack {
                                    Circle()
                                    
                                    Text("시작하기")
                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            Button {
                                
                            } label: {
                                ZStack {
                                    Circle()
                                    
                                    Image("airpodsconnect")
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .padding(8)
                                }
                                .frame(width: 80, height: 80)
                            }
                        }
                        .foregroundStyle(.black)
                    }
                    .padding()
                    
                    RoundedButton(title: "자세 설정", font: .footnote, foregroundColor: .white, backgroundColor: .secondary, rotatingAnimation: true) {
                        showPostureSetting = true
                    }
                }
                .navigationTitle("Run")
                .navigationBarTitleDisplayMode(.large)
            }
        }
        .sheet(isPresented: $showPostureSetting) {
            PostureDashboardView()
        }
    }
}

#Preview {
    MainView()
}
