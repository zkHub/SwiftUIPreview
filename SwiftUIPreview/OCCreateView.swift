//
//  OCCreateView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/5/26.
//

import SwiftUI

let sectionsJson = """
[
  {
    "key": "basic_info",
    "title": "Basic Information",
    "items": [
      {
        "key": "avatar",
        "title": "Avatar",
        "placeholder": "Change One",
        "required": true
      },
      {
        "key": "name",
        "title": "Name",
        "placeholder": "Give your avatar a name~",
        "required": true
      },
      {
        "key": "gender",
        "title": "Gender",
        "placeholder": "Are they a boy, girl, or non-binary?~",
        "required": false
      },
      {
        "key": "age",
        "title": "Age",
        "required": false
      },
      {
        "key": "birthday",
        "title": "Birthday",
        "required": false
      },
      {
        "key": "species",
        "title": "Species",
        "placeholder": "Are they human, elf, animal, or another species?",
        "required": false
      },
      {
        "key": "introduction",
        "title": "Introduction",
        "placeholder": "Briefly introduce them to everyone",
        "required": false
      }
    ]
  },
  {
    "key": "appearance",
    "title": "Appearance",
    "items": [
      {
        "key": "height",
        "title": "Height",
        "required": false
      },
      {
        "key": "weight",
        "title": "Weight",
        "required": false
      },
      {
        "key": "special_features",
        "title": "Special Features",
        "placeholder": "Maybe they have special eyes~",
        "required": false
      },
      {
        "key": "clothing_style",
        "title": "Clothing Style",
        "placeholder": "Maybe they're sweet-cool or gentle and lovely...",
        "required": false
      }
    ]
  },
  {
    "key": "personality",
    "title": "Personality",
    "items": [
      {
        "key": "mbti",
        "title": "MBTI",
        "required": false
      },
      {
        "key": "strengths",
        "title": "Strengths",
        "required": false
      },
      {
        "key": "weaknesses",
        "title": "Weaknesses",
        "required": false
      },
      {
        "key": "hobbies",
        "title": "Hobbies",
        "required": false
      }
    ]
  },
  {
    "key": "background",
    "title": "Background",
    "items": [
      {
        "key": "experience",
        "title": "Experience",
        "placeholder": "Maybe they have a mysterious past, tell everyone~",
        "required": false
      },
      {
        "key": "future_goals",
        "title": "Future Goals",
        "placeholder": "What do they aspire to in the future? To save the world?!!!",
        "required": false
      },
      {
        "key": "important_person",
        "title": "Most Important Person",
        "placeholder": "Maybe they have someone they love the most",
        "required": false
      }
    ]
  },
  {
    "key": "skills",
    "title": "Skills",
    "items": [
      {
        "key": "combat_abilities",
        "title": "Combat/Special Abilities",
        "placeholder": "Maybe they're great at styling, a sports expert, or have supernatural abilities...",
        "required": false
      },
      {
        "key": "occupation",
        "title": "Occupation/Identity",
        "placeholder": "Are they a doctor, police officer, hacker, student, or hero...?",
        "required": false
      }
    ]
  },
  {
    "key": "worldview",
    "title": "Worldview",
    "items": [
      {
        "key": "era",
        "title": "Era",
        "placeholder": "Do they belong to the modern, ancient, future, or a 2D world?",
        "required": false
      },
      {
        "key": "alignment",
        "title": "Alignment",
        "placeholder": "Good or Evil",
        "required": false
      },
      {
        "key": "worldview",
        "title": "Worldview",
        "placeholder": "Idealist, Realist, Pessimist, or Hedonist",
        "required": false
      }
    ]
  }
]
"""



struct OCInfoSection: Identifiable, Codable {
    var id: String { key }
    let key: String
    let title: String
    let items: [OCInfoItem]
}

struct OCInfoItem: Identifiable, Codable {
    var id: String { key }
    let key: String
    let title: String
    let placeholder: String?
    let required: Bool?
}


struct OCCreateView: View {
    @State private var selectedIndex  = 0
    @State private var formData: [String: [String: String]] = [:] // key: value
    @State private var avatarImage: UIImage?
    @State private var scrollOffset: CGFloat = 0

    var sections: [OCInfoSection]? {
        if let jsonData = sectionsJson.data(using: .utf8) {
            do {
                let sections = try JSONDecoder().decode([OCInfoSection].self, from: jsonData)
                print(sections)
                return sections
            } catch {
                print("解析失败：\(error)")
                return nil
            }
        }
        return nil
    }
    var currentSection: OCInfoSection? {
        sections?[selectedIndex]
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Create OC")
                Spacer()
                Button {
                    print(formData)
                } label: {
                    Text("Set")
                }

            }
            
            HStack(spacing: 0) {
                // 左侧导航
                VStack {
                    if let sections, !sections.isEmpty {
                        ForEach(sections.indices, id: \.self) { index in
                            let section = sections[index]
                            Button {
                                selectedIndex = index
                            } label: {
                                Text(section.title)
                            }
                            .background(selectedIndex == index ? .white : .clear)
                        }
                    }
                    Spacer()
                }
                .padding()
                .frame(width: 100)
                .background(Color(.systemGray6))
                
                if let currentSection {
                    // 右侧表单
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            ForEach(currentSection.items) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        if let required = item.required, required {
                                            Text("*\(item.title)")
                                                .foregroundColor(.pink)
                                        } else {
                                            Text(item.title)
                                        }
                                        Spacer()
                                    }
                                    AutoGrowingTextEditor(
                                        text: Binding(
                                            get: {
                                                formData[currentSection.key]?[item.key] ?? ""
                                            },
                                            set: {
                                                formData[currentSection.key, default: [:]][item.key] = $0
                                            }
                                        ),
                                        placeholder: item.placeholder ?? ""
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .onChange(of: geometry.frame(in: .named("scroll")).minY) { newValue in
                                        DispatchQueue.main.async {
                                            scrollOffset = newValue
                                        }
                                    }
                            }
                        )
                    }
                    .coordinateSpace(name: "scroll")
                    .simultaneousGesture(
                        DragGesture()
                            .onEnded { _ in
                                evaluateScrollTrigger()
                            }
                    )
                }
            }
        }
        .navigationTitle("OC")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Set") {
                }
            }
        }
        .onAppear {
            
            
        }
    }
    
    private func evaluateScrollTrigger() {
        let upThreshold: CGFloat = -120
        let downThreshold: CGFloat = 120

        if scrollOffset < upThreshold  {
            // 向上拖动到最底部
            if let sections = sections, selectedIndex < sections.count - 1 {
                withAnimation {
                    selectedIndex += 1
                }
            }
        } else if scrollOffset > downThreshold  {
            // 向下拖动到最顶部
            if selectedIndex > 0 {
                withAnimation {
                    selectedIndex -= 1
                }
            }
        }
    }
    

}


struct AutoGrowingTextEditor: View {
    @Binding var text: String
    var placeholder: String = ""
    var maxCharacters: Int = 100
    var minHeight: CGFloat = 40
    var maxHeight: CGFloat = 200

    @State private var dynamicHeight: CGFloat = 40

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .frame(minHeight: dynamicHeight, maxHeight: maxHeight)
                .background(GeometryReader {
                    Color.clear.preference(key: TextEditorHeightKey.self,
                                           value: $0.size.height)
                })
                .onPreferenceChange(TextEditorHeightKey.self) { newHeight in
                    let clamped = min(max(newHeight, minHeight), maxHeight)
                    if abs(dynamicHeight - clamped) > 1 {
                        dynamicHeight = clamped
                    }
                }
                .onChange(of: text) { newText in
                    if newText.count > maxCharacters {
                        text = String(newText.prefix(maxCharacters))
                    }
                }
                .padding(4)
            
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3))
        )
    }
}

private struct TextEditorHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 40
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

    
#Preview(body: {
    OCCreateView()
})
