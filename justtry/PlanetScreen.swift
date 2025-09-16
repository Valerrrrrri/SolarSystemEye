//
//  PlanetScreen.swift
//  justtry
//
//  Created by Valery Mokrytska on 04.10.25.
//

import SwiftUI

struct PlanetScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            StarBackground().ignoresSafeArea()   // ⭐ единый фон
            content()
                .ignoresSafeArea()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
