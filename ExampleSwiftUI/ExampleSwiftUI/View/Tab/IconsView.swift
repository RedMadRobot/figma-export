//
//  IconsView.swift
//  ExampleSwiftUI
//
//  Created by Daniil Subbotin on 11.09.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import SwiftUI

struct IconsView: View {
    
    var images = [
        Image.ic16KeyEmergency,
        Image.ic16KeySandglass,
        Image.ic16Notification,
        Image.ic24ArrowRight,
        Image.ic24Close,
        Image.ic24Dots,
        Image.ic24DropdownDown,
        Image.ic24DropdownUp,
        Image.ic24FullscreenDisable,
        Image.ic24FullscreenEnable,
        Image.ic24ShareIos
    ]
    
    var body: some View {
        TabStackedView(tabTitle: "Icons") {
            ForEach(0..<self.images.count) { index in
                self.images[index]
            }
            Spacer()
        }
        .foregroundColor(.tint)
    }
}

struct IconsView_Previews: PreviewProvider {
    static var previews: some View {
        IconsView()
    }
}
