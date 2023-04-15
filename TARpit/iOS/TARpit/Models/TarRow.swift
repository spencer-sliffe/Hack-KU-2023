//
//  TarRow.swift
//  TARpit
//
//  Created by Spencer SLiffe on 4/14/23.
//

import Foundation
import SwiftUI

struct TarRow: View {
    @EnvironmentObject var viewModel: TarPitViewModel
    let tarPost: TarPost
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }
    
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(tarPost.title)
                .font(.headline)
            HStack {
                Text("By \(tarPost.author)")
                Spacer()
                Text("\(tarPost.timestamp, formatter: dateFormatter)")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            Text(tarPost.description)
                .font(.body)
            
            if let imageURL = tarPost.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.width * 0.55)
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}
