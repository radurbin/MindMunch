//
//  Loading.swift
//  DeviceActivityApp
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

// Loading.swift
import SwiftUI

struct Loading: View {
    
    private let text: String
    private let scale: Double
    
    init(text: String, scale: Double = 1.5) {
        self.text = text
        self.scale = scale
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView {
                    Text(text)
                }
                .foregroundColor(.white)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .font(.title3)
                .controlSize(.large)
                .scaleEffect(scale)
                .foregroundColor(.white)
            }
        }
    }
}

struct Loading_Previews: PreviewProvider {
    static var previews: some View {
        Loading(text: "please wait...")
    }
}
