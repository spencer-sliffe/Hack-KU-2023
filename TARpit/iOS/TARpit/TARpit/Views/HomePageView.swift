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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            NavigationView {
                ZStack {
                    if !authViewModel.isAuthenticated {
                        AuthView(authViewModel: authViewModel)
                    } else {
                        TabView(selection: $selectedTab) {
                            
                            AccountView(authViewModel: authViewModel)
                                .tag(0)
                            TarPitView()
                                .tag(1)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .navigationBarHidden(true)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
            .environmentObject(AuthViewModel())
    }
}
