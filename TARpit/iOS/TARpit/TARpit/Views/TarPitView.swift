//
//  TarPostView.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation
import SwiftUI

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
                Spacer()
                Text("\(Date(), formatter: timeFormatter)")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
        }.frame(height: 20)
        Spacer()
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.posts.sorted(by: { $0.timestamp > $1.timestamp }).filter(isPostTypeVisible)) { post in
                    PostRow(post: post)
                        .environmentObject(viewModel)
                        .background(Color.clear)
                }
            }
        }
        .background(Color.clear)
        customToolbar()
    }
    .background(
        LinearGradient(
            gradient: Gradient(colors: [.black, .blue]),
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

extension View {
func listBackground(_ color: Color) -> some View {
    modifier(ListBackgroundModifier(color: color))
}
}

private struct ListBackgroundModifier: ViewModifier {
let color: Color

@ViewBuilder
func body(content: Content) -> some View {
    content
        .background(color)
        .listRowBackground(color)
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
        }
}
}
