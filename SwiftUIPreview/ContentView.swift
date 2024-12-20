//
//  ContentView.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/8/28.
//

import SwiftUI

struct ContentView: View {
    
    @State private var random1: Int = 0
    @State private var random2: Int = 0
    
    var body: some View {
        NavigationView(content: {
            List {
                Button {
                    differentForSKAdNetworks()
                } label: {
                    Text("SKAdNetworks Diff")
                }
                NavigationLink(destination: MoreTextView()) { Text("MoreTextView") }
                NavigationLink(destination: ColorView()) { Text("ColorView") }
                NavigationLink(destination: FontView()) { Text("FontView") }
                NavigationLink(destination: MakeStickerView()) { Text("MakeStickerView") }
                NavigationLink(destination: MakeStickerEidtorView()){Text("MakeStickerVCRepresentable")}
            }
            
        })
        .onAppear(perform: {
            for _ in 0..<100 {
                let random = Int.random(in: 0..<1000)
                if random % 2 == 0 {
                    random2 += 1
                } else {
                    random1 += 1
                }
            }
            print(random1, random2)
        })
    }
    
    
    func differentForSKAdNetworks() {
        
        let array1 = getPlist(name: "skad1")!.map {
            $0.values.first! as String
        }
        var array2 = getPlist(name: "skad2")!.map {
            $0.values.first! as String
        }
        for (_, a2) in array2.enumerated() {
            if array1.contains(a2) {
                array2.removeAll { str in
                    str == a2
                }
            }
        }
        
        print("SKAdNetworks Diff:", array2)
    }

    func getPlist(name: String) -> [[String: String]]? {
        if let url = Bundle.main.url(forResource: name, withExtension: "plist") {
            do {
                let data = try Data(contentsOf: url)
                if let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [[String: String]] {
                    return plist
                }
            } catch {
                print("Error reading plist: \(error)")
            }
        }
        return nil
    }
    
}


#Preview {
    ContentView()
}
