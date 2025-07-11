//
//  ContentView.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/8/28.
//

import SwiftUI
import Kingfisher
import KingfisherWebP
import Lottie

struct ContentView: View {
    
    @State private var random1: Int = 0
    @State private var random2: Int = 0
    
    var body: some View {
        NavigationView(content: {

            List {
                
                LottieView(animation: .named("swipeLeft"))
                    .playing(loopMode: .loop)  // 或 .playing(), .paused()
                    .frame(width: 200, height: 200)
                    .background(Color.black)
                
                LottieView {
                    try await DotLottieFile.named("swipeLeft1")  // 加载 .lottie 文件
                }
                .playing(loopMode: .loop)
                .frame(width: 200, height: 200)
                .background(Color.black)

                Text("地方的地方地方的地方大幅度发的大")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Image("Group245")
                    )
                    .background(.black)
                
//                if let url = Bundle.main.url(forResource: "1", withExtension: "webp") {
//                    KFAnimatedImage(URL(string: "https://img-push.zthd.io/us/cdns/47dc17e7661b548cac6db13a1d66cfac.webp"))
//                    KFAnimatedImage(url)
//                }
                                
                
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
                
                NavigationLink(destination: DrawingView()) { Text("CanvasView") }
                NavigationLink(destination: DrawingOverlayView(baseImage: UIImage(named: "2")!)) { Text("DrawingOverlayView") }
                NavigationLink(destination: PKDrawingView()) { Text("PKDrawingView") }
                
                NavigationLink("CustomDragSortView", destination: CustomDragSortView())
                
                NavigationLink("DragReorderListView", destination: DragReorderListView())
                NavigationLink("OCCreateView", destination: OCCreateView())

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
        let array1 = getPlist(name: "skad1")!["SKAdNetworkItems"]!.map {
            $0.values.first! as String
        }
        duplicates(array: array1)
        var array2 = getPlist(name: "skad2")!["SKAdNetworkItems"]!.map {
            $0.values.first! as String
        }
        duplicates(array: array2)
        for (_, a2) in array2.enumerated() {
            if array1.contains(a2) {
                array2.removeAll { str in
                    str == a2
                }
            }
        }
        
        print("SKAdNetworks Diff:", array2)
    }
    
    func duplicates(array: [String]) {
        var counts: [String: Int] = [:]
        for item in array {
            counts[item, default: 0] += 1
        }

        let duplicates = counts.filter { $0.value > 1 }.map { $0.key }
        print("duplicates: ", duplicates)  // 输出: [2, 3]
    }

    func getPlist(name: String) -> [String : [[String: String]]]? {
        if let url = Bundle.main.url(forResource: name, withExtension: "plist") {
            do {
                let data = try Data(contentsOf: url)
                if let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String : [[String: String]]] {
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
