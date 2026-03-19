//
//  ContentSwiftUITypeView.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import SwiftUI
import ComposableArchitecture

struct ContentSwiftUITypeView: View {
    let store: StoreOf<ContentFeature>
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
//    ContentSwiftUITypeView(store: Store(initialState: ContentFeature.State(), reducer: { ContentFeature() }))
}
