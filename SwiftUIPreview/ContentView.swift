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
import DefaultCodable
import BetterCodable

 enum Dictaa: DefaultValueProvider {
    public static let `default` = ["1": "1"]
}

struct Testss: Codable {
    var v: Int = 1
    var s: String?
    
    @Default<Empty>
    var a: [String]
    
    @Default<False>
    var b: Bool

    @DefaultEmptyDictionary
    var d1: [String: String]
    
    @Default<Dictaa>
    var d2: [String: String]
}

struct ContentView: View {
    
    @State private var random1: Int = 0
    @State private var random2: Int = 0
    @State var showTabTest = false
    
    
    
    var body: some View {
        NavigationView(content: {

            List {
                
                NavigationLink("SpineEditorView", destination: SpineEditorView(templateId: "hSXG11sA", portal: ""))
                NavigationLink("VAPDemoView", destination: VAPDemoView())

                NavigationLink("TabScrollSafeAreaTest", destination: TabScrollSafeAreaTest())
                NavigationLink("TextContentView", destination: TextContentView())
                NavigationLink("TestView", destination: TestView())
                NavigationLink("TapLikeAnimationView", destination: TapLikeAnimationView())

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
                    showTabTest = true
                } label: {
                    Text("SKAdNetworks Diff")
                }
                NavigationLink(destination: MoreTextView()) { Text("MoreTextView") }
                NavigationLink(destination: AColorView()) { Text("ColorView") }
                NavigationLink(destination: FontView()) { Text("FontView") }
                NavigationLink(destination: MakeStickerView()) { Text("MakeStickerView") }
                NavigationLink(destination: MakeStickerEidtorView()){Text("MakeStickerVCRepresentable")}
                
                NavigationLink(destination: DrawingView()) { Text("CanvasView") }
                NavigationLink(destination: DrawingOverlayView(baseImage: UIImage(named: "2")!)) { Text("DrawingOverlayView") }
                NavigationLink(destination: PKDrawingView()) { Text("PKDrawingView") }
                
                NavigationLink("StrokeText", destination: StrokeTextPreview())

                NavigationLink("CustomDragSortView", destination: CustomDragSortView())
                
                NavigationLink("DragReorderListView", destination: DragReorderListView())
                NavigationLink("OCCreateView", destination: OCCreateView())

                NavigationLink("WheelPickerView", destination: WheelPickerView(store: WheelPickerStore(options: (0..<10).map { "Option \($0)" })))
                
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
            
            let value = """
            {"v": 1, "a": []}
            """
            if let data = value.data(using: .utf8), let t = try? JSONDecoder().decode(Testss.self, from: data) {
                print(t.v, t.s, t.b, t.a, t.d1, t.d2)
            }
//            let t = Testss()
//            print(t.v, t.s, t.a, t.d1, t.d2)
        })
        .overlay {
            if showTabTest {
                TabScrollSafeAreaTest()
                    .onTapGesture {
                        showTabTest = false
                    }
            }
        }
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
