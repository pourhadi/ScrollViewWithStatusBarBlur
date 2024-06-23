//
//  ScrollViewWithStatusBarBlur.swift
//  ScrollViewWithStatusBarBlur
//
//  Created by Daniel Pourhadi on 6/23/24.
//

import SwiftUI

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public struct ScrollViewWithStatusBarBlur<Content, Background>: View where Content: View, Background: View {
    let content: Content
    let background: Background
    
    public init(@ViewBuilder _ content: @escaping () -> Content,
                background: @escaping () -> Background = { Color.white }) {
        self.content = content()
        self.background = background()
    }
    
    @State var image: UIImage? = nil
    @Environment(\.displayScale) var scale
    @State var scrollOffset: CGFloat = 0
    
    public var body: some View {
        GeometryReader { outer in
            ScrollView {
                content
                    .frame(maxWidth: .infinity)
                    .background {
                        background
                    }
                    .coordinateSpace(name: "content")
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: -proxy.frame(in: .named("content")).minY)
                            .onPreferenceChange(ScrollOffsetKey.self, perform: { value in
                                    scrollOffset = value
                                })
                        }
                    }
                    .task {
                        let renderer = ImageRenderer(content: content
                            .opacity(0.9)
                            .frame(width: outer.size.width)
                            .background {
                               background
                            }
                        )
                        renderer.isOpaque = true
                        renderer.scale = scale
                        image = renderer.uiImage
                    }
            }
            .overlay(alignment: .top) {
                if let image = image {
                    Image(uiImage: image)
                        .frame(maxWidth: .infinity)
                        .mask(alignment: .top) {
                            VStack(spacing: 0) {
                                Rectangle()
                                    .fill(.black)
                                    .frame(height: 100)
                                LinearGradient(colors: [.black, .black, .clear], startPoint: .top, endPoint: .bottom)
                                    .frame(height: outer.safeAreaInsets.top + 20)

                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: outer.size.height)
                            }
                            .offset(y: scrollOffset - 100)
                        }
                        .offset(y: -scrollOffset)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .blur(radius: 10, opaque: false)
                }
            }
        }
    }
}
