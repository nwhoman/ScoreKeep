//
//  SideMenuView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 5/12/26.
//

import SwiftUI

struct BookMenuView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var nav: NavigationStateManager
    
    @State var showMenu: Bool = false
    @State var selectedTab: Int = 0
    @State var navTitle: String = ""
    @State var gameViewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                TabView(selection: $selectedTab) {
                    
                    ForEach(SideMenuOptionModel.allCases) { each in
                        if each == .bookview {
                            BookView(gameViewModel: $gameViewModel)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, -5)
                                .toolbar(.hidden, for: .tabBar)
                        } else if each == .boxscore {
                            BoxScoreView(gameViewModel: gameViewModel, geo: geo)
                                .padding(.horizontal, 10)
                                .toolbar(.hidden, for: .tabBar)
                        } else if each == .gameoptions {
                            GameOptionsView(gameVM: $gameViewModel, geo: geo)
                                .padding(.horizontal, 10)
                                .toolbar(.hidden, for: .tabBar)
                        } else if each == .quicksubs {
                            QuickSubsView(gameVM: $gameViewModel, geo: geo)
                                .padding(.horizontal, 10)
                                .toolbar(.hidden, for: .tabBar)
                        } else if each == .rules {
                            Text(each.title)
                                .tag(each.id)
                        } else {
                            Text(each.title)
                                .tag(each.id)
                        }
                    }
                }
                SlideoutMenuView(isShowing: $showMenu, selectedTab: $selectedTab, navTitle: $navTitle, geo: geo)
            }
            .frame(width: geo.size.width)
            .toolbar(showMenu ? .hidden : .visible, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            //.navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showMenu.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .padding()
        }
        .ignoresSafeArea(edges: .all)
        .navigationBarBackButtonHidden()
    }
        
}

#Preview {
    let preview = Preview()
    let gameViewModel: GameViewModel = GameViewModel.defaultGame
    preview.addSampleGames([gameViewModel])
    preview.addSampleLineups(game: gameViewModel)
    return GeometryReader { geo in
         BookMenuView(gameViewModel: gameViewModel)//showMenu: .constant(false), selectedTab: .constant(0), navTitle: .constant("")
    }
}

struct SlideoutMenuView: View {
    @EnvironmentObject var nav: NavigationStateManager

    @Binding var isShowing: Bool
    @State private var selectedOption: SideMenuOptionModel? = nil
    @Binding var selectedTab: Int
    @Binding var navTitle: String
    let geo: GeometryProxy
    
    var body: some View {
        ZStack {
            if isShowing {
                Rectangle()
                    .frame(width: geo.size.width)
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }
                HStack {
                    VStack {
                        MenuHeaderView()
                        VStack {
                            ForEach(SideMenuOptionModel.allCases) { each in
                                if each != .mainmenu {
                                    Button {
                                        selectedOption = each
                                        selectedTab = each.id
                                        isShowing.toggle()
                                        navTitle = each.title
                                    } label: {
                                        SideMenuRowView(option: each, selectedOption: $selectedOption)
                                    }
                                } else {
                                    Button {
                                        nav.popToRoot()
                                    } label: {
                                        SideMenuRowView(option: each, selectedOption: $selectedOption)
                                    }
                                }
                                
                                
                            }
                        }
                        Spacer()
                        
                    }
                    .padding()
                    .frame(width: geo.size.width*0.75)
                    .background(Color(.systemBackground))
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
        
        .animation(.easeInOut, value: isShowing)
        
    }
        
}

#Preview {
    return GeometryReader { geo in
        SlideoutMenuView(isShowing: .constant(true), selectedTab: .constant(0), navTitle: .constant("neal"), geo: geo)
    }
}

struct MenuHeaderView: View {
    
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.vertical)
            VStack(alignment: .leading, spacing: 6) {
                Text("ScoreKeep")
                    .font(.subheadline)
                Text("game options")
                    .font(.footnote)
                    .tint(.gray)
            }
            Spacer()

        }
            
        
    }
        
}

//#Preview {
//    MenuHeaderView()
//}

struct SideMenuRowView: View {
    
    let option: SideMenuOptionModel
    @Binding var selectedOption: SideMenuOptionModel?
    
    private var isSelected: Bool {
        selectedOption == option
    }
    
    var body: some View {
        HStack {
            Image(systemName: option.systemImageName)
                .imageScale(.small)
            Text(option.title)
                .font(.subheadline)
            Spacer()
        }
        .padding(.leading)
        .foregroundStyle(isSelected ? .blue : .primary)
        .frame(width: 216, height: 44)
        .background(isSelected ? .blue.opacity(0.15) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
        
}

//#Preview {
//    SideMenuRowView()
//}

enum SideMenuOptionModel: Int, CaseIterable, Identifiable {
    case bookview
    case boxscore
    case gameoptions
    case quicksubs
    case rules
    case mainmenu
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .bookview: return "BookView"
        case .boxscore: return "Boxscore"
        case .gameoptions: return "Game Options"
        case .quicksubs: return "Quick Substitutions"
        case .rules: return "Rule Book"
        case .mainmenu: return "Main Menu"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .bookview: return "book"
        case .boxscore: return "filemenu.and.cursorarrow"
        case .gameoptions: return "chart.bar"
        case .quicksubs: return "person"
        case .rules: return "magnifyingglass"
        case .mainmenu: return "backward.fill"
        }
    }
}
