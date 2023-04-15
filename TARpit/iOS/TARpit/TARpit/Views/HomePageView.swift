//
//  HomePageView.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation
import SwiftUI

struct HomePageView: View {
    @State private var selectedTab = 2
    @ObservedObject var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if !authViewModel.isAuthenticated {
                    AutheView(authViewModel: authViewModel)
                } else {
                    TabView(selection: $selectedTab) {
                        
                        AccountView(authViewModel: authViewModel)
                            .tag(0)
                        TarPitView()
                            .tag(0)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .navigationBarHidden(true)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.black, .blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
