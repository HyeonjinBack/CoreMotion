//
//  MainView.swift
//  CoreMotionWear
//
//  Created by 백현진 on 2/24/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack {
                
                HStack(spacing: 16) {
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
            }
            .navigationTitle("Run")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MainView()
}
