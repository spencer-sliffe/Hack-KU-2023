//
//  TarPostView.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation
import SwiftUI

struct TarPitView: View {
    @State private var isPresentingCreatePostView = false
    @ObservedObject var viewModel = TarPitViewModel()
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"
        return formatter
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack {
                    Text("\(Date(), formatter: dateFormatter)")
                        .foregroundColor(.white)
                    Spacer()
                    Text("TARpit")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Date(), formatter: timeFormatter)")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
            .frame(height: 20)
            Spacer()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.tarPosts.sorted(by: { $0.timestamp > $1.timestamp })) { tarPost in
                        TarRow(tarPost: tarPost)
                            .environmentObject(viewModel)
                            .background(Color.clear)
                    }
                }
            }
            .background(Color.clear)
            Button(action: {
                isPresentingCreatePostView.toggle()
            }) {
                Text("Create Post")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .edgesIgnoringSafeArea(.bottom)
        
        .onAppear {
            viewModel.fetchPosts()
        }
        .sheet(isPresented: $isPresentingCreatePostView) {
            CreatePostView().environmentObject(viewModel)
        }
    }
}
