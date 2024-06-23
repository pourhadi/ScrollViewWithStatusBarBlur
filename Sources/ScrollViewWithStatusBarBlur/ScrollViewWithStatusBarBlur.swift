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
    let blurRadius: CGFloat
    let topPadding: CGFloat
    let contentOpacity: CGFloat
    let rerenderFlag: Bool
    
    public init(background: Background = Color.white,
                blurRadius: CGFloat = 8.0,
                topPadding: CGFloat = 10,
                contentOpacity: CGFloat = 0.9,
                rerenderFlag: Bool = false,
                @ViewBuilder _ content: @escaping () -> Content) {
        self.content = content()
        self.background = background
        self.blurRadius = blurRadius
        self.topPadding = topPadding
        self.contentOpacity = contentOpacity
        self.rerenderFlag = rerenderFlag
    }
    
    @State var image: UIImage? = nil
    @Environment(\.displayScale) var scale
    @State var scrollOffset: CGFloat = 0
    
    public var body: some View {
        GeometryReader { outer in
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: topPadding)
                    content
                }
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
                    render(outer: outer)
                }
                .onChange(of: rerenderFlag) { oldValue, newValue in
                    render(outer: outer)
                }
            }
            .overlay(alignment: .top) {
                if let image = image {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: topPadding)
                        Image(uiImage: image)
                            .frame(maxWidth: .infinity)
                    }
                    .background { background }
                    .ignoresSafeArea()

                    .mask(alignment: .top) {
                        VStack(spacing: 0) {
                            Color.black.frame(height: outer.safeAreaInsets.top + (topPadding * 2) - 10)
                            LinearGradient(colors: [.black, .clear],
                                           startPoint: .top,
                                           endPoint: .bottom)
                            .frame(height: 10)
                            Rectangle()
                                .fill(.clear)
                                .frame(height: outer.size.height)
                        }
                        .offset(y: scrollOffset + outer.safeAreaInsets.top - topPadding)
                    }
                    .drawingGroup()
                    .blur(radius: blurRadius, opaque: false)

                    .offset(y: -scrollOffset - outer.safeAreaInsets.top - topPadding)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    
                }
            }
        }
        
    }
    
    @MainActor
    func render(outer: GeometryProxy) {
        let renderer = ImageRenderer(content:
                                        VStack(spacing: 0) {
            Color.clear.frame(height: outer.safeAreaInsets.top + topPadding)
            content
        }
            .opacity(contentOpacity)
            .frame(width: outer.size.width + outer.safeAreaInsets.leading + outer.safeAreaInsets.trailing)
            .background {
                background
                    .ignoresSafeArea()
            }
                                     
        )
        renderer.isOpaque = true
        renderer.scale = scale
        image = renderer.uiImage
    }
}
