//
//  GamesView.swift
//  ScoreKeep
//
//  Created by Neal Homan on 4/10/24.
//

import SwiftData
import SwiftUI

struct GamesView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var nav: NavigationStateManager
    @Query(sort: \GameViewModel.id) private var viewModels: [GameViewModel]
    
    @State private var showAddGameScreen = false
    //@State var startGame: Game = Game(name: "", date: Date(), location: "")
    //@Binding var path: NavigationPath
    @State var JSONString: String = ""
    @State var showJSON: Bool = false
    @State var isLoading: Bool = false    
    
    var body: some View {
        GeometryReader { geo in
        
        
        List {
            ForEach(viewModels, id: \.id) { vm in //.sorted(by: { $0.game.date < $1.game.date })
                
                Button {
                    nav.push(.bookView(gameViewModel: vm))

                } label: {
                    
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(vm.name)")
                                    .font(.headline)
                                
                                Spacer()
                                if vm.isComplete {
                                    Text("X")
                                } else {
                                    Text("O")
                                }
                            }
                            Text("\(vm.date.formatted(date: .complete, time: .shortened))")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                //
            }
            .onDelete(perform: deleteVM)
        }
            
            
            .navigationTitle("ScoreKeep Games")
            .toolbar{
                
                ToolbarItem(placement: .topBarLeading){
                    //EditButton()
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button("Add Game", systemImage: "plus"){
                        showAddGameScreen.toggle()
                    }
                }
            }
            .navigationDestination(isPresented: $showAddGameScreen){
                StartGameView()
                //StartGameView(path: $path)
            }
        }
            .sheet(isPresented: $showJSON) {
                ScrollView {
                    Text(JSONString)
                }
            }
    }
    
    
    
    func deleteVM(at offsets: IndexSet){
        for offset in offsets {
            let viewModel = viewModels[offset]
            //let viewModel = viewModels.sorted(by: { $0.date < $1.date })[offset]
            for each in viewModel.innings {
                viewModel.innings.remove(at: offset)
                modelContext.delete(each)
            }
            modelContext.delete(viewModel)
        }
        do {
            try modelContext.save()
        } catch {
            print("error \(error)")
        }
    }
    
}

#Preview {
    let preview = Preview()
    let game = GameViewModel.defaultGame
    preview.addSampleGames([game])
    preview.addSampleLineups(game: game)
        
    return NavigationStack {
        GamesView().modelContainer(preview.modelContainer)
    }
}

//func displayJSON(game: Game) -> String {
//    var newGameViewModel: GameViewModel
//    let decoder = JSONDecoder()
//    guard let newGVM: GameViewModel = try? decoder.decode(GameViewModel.self, from: game.viewModel.last!) else {
//        print("no model to decode")
//        return "no model to decode"
//    }
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = [.prettyPrinted]
//    if let jsonData = try? encoder.encode(newGVM),
//       let jsonString = String(data: jsonData, encoding: .utf8) {
//        print("saved game: \(game.viewModel.count) \n \(jsonString)")
//        return jsonString
//    }
    //return "failed to encode game"
//}

//class DataLoader: ObservableObject {
//    @Environment(\.modelContext) var modelContext
//    @Published var games: [GameViewModel] = []
//    var storedGames: [Game]
//
//    init(storedGames: [Game]) {
//        self.storedGames = storedGames
//        loadData()
//    }
//
//    func loadData() {
//        do {
//            print("in data loader: \(storedGames.count)")
//            for game in storedGames {
//                print("in data loader: \(game.homeTeam!.name) \(game.viewModel.count)")
//                let decoder = JSONDecoder()
//                let newGVM: GameViewModel = try decoder.decode(GameViewModel.self, from: game.viewModel.last!)
//                
//                DispatchQueue.main.async {
//                    
//                    self.games.append(newGVM)
//                }
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = [.prettyPrinted]
//                if let jsonData = try? encoder.encode(newGVM),
//                   let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print("data loader saved game:" + jsonString)
//                }
//            }
//        } catch {
//            print("Unresolved error \(error), \(error._domain)")
//        }
//    }
//}
