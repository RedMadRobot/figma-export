//
//  ContentView.swift
//  ExampleSwiftUI
//
//  Created by Daniil Subbotin on 10.09.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ColorsView()
            .tabItem {
                Image(systemName: "paintbrush.fill")
                Text("Colors")
            }
            
            IllustrationsView()
            .tabItem {
                Image(systemName: "cube.box.fill")
                Text("Illustrations")
            }
            
            IconsView()
            .tabItem {
                Image(systemName: "archivebox.fill")
                Text("Icons")
            }
            
            TypographyView()
            .tabItem {
                Image(systemName: "text.bubble.fill")
                Text("Typography")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
