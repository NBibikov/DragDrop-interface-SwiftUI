//
//  Home.swift
//  Drag&Drop interface SwiftUI (iOS)
//
//  Created by Mykola Bibikov on 02.04.2022.
//

import SwiftUI

struct Home: View {
    
    @State var progress: CGFloat = 0
    @State var characters: [Character] = characters_
    /// For Drag Part
    @State var shuffledRows: [[Character]] = []
    /// For Drop Part
    @State var rows: [[Character]] = []
    /// Wrong animation key
    @State var animatedWrongText = false
    @State var droppedCounter: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 15) {
            NavBar()
            VStack(alignment: .leading, spacing: 30) {
                Text("Form the sentece")
                    .font(.title2.bold())
                Image("Character")
                    .resizable()
                    .scaledToFit()
                    .padding(.trailing, UIScreen.main.bounds.width * 0.5)
            }
            .padding(.leading, 12)
            .padding(.top, 20)
            
            // MARK: Drag&Drop zone
            DropArea()
                .padding(.vertical, 30)
            DragArea()
        }
        .padding()
        .onAppear{
            if rows.isEmpty {
                fillData()
            }
        }
        .offset(x: animatedWrongText ? -30 : 0)
    }
    
    // MARK: Drop Area
    @ViewBuilder
    func DropArea() -> some View {
        VStack(spacing: 12) {
            ForEach($rows, id: \.self) { $row in
                HStack(spacing: 10) {
                    ForEach($row) { $item in
                        Text(item.value)
                            .font(.system(size: item.fontSize))
                            .padding(.vertical, 5)
                            .padding(.horizontal, item.padding)
                            .opacity(item.isShowing ? 1 : 0)
                            .background{
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(item.isShowing ? .clear : .gray.opacity(0.25))
                            }
                            .background{
                                // if item is Dropped into correct place
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(.gray)
                                    .opacity(item.isShowing ? 1 : 0)
                            }
                            .onDrop(of: [.url], isTargeted: .constant(false)) { providers in
                                if let first = providers.first {
                                    let _ = first.loadObject(ofClass: URL.self) { value, error in
                                        guard let url = value else { return }
                                        if item.id == "\(url)" {
                                            droppedCounter += 1
                                            let progress = droppedCounter / CGFloat(characters.count)
                                            withAnimation {
                                                item.isShowing = true
                                                updateShuffledArray(item)
                                                self.progress = progress
                                            }
                                        } else {
                                            // wrong flow animation
                                            animateView()
                                        }
                                    }
                                }
                                return false
                            }
                    }
                }
                if rows.last != row {
                    Divider()
                }
            }
        }
    }
    
    // MARK: Drap Area
    @ViewBuilder
    func DragArea() -> some View {
        VStack(spacing: 12) {
            ForEach(shuffledRows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row) { item in
                        Text(item.value)
                            .font(.system(size: item.fontSize))
                            .padding(.vertical, 5)
                            .padding(.horizontal, item.padding)
                            .background{
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(.gray)
                            }
                            .onDrag{
                                // return ID to find wich item is moving
                                return .init(contentsOf: URL(string: item.id))!
                            }
                            .opacity(item.isShowing ? 0 : 1)
                            .background{
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(item.isShowing ? .gray.opacity(0.25) : .clear)
                            }
                    }
                }
                if shuffledRows.last != row {
                    Divider()
                }
            }
        }
    }
    
    // MARK: Custom Nav Bar
    @ViewBuilder
    func NavBar() -> some View {
        HStack(spacing: 18) {
            Button {
                fillData()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            GeometryReader{proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.gray.opacity(0.25))
                    Capsule()
                        .fill(Color("Green"))
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 20)
            
            Button {
                
            } label: {
                Image(systemName: "suit.heart.fill")
                    .font(.title3)
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: Generation custom grid columns
    func generateGrid() -> [[Character]] {
        //step 1: indentify width for each text element and update it into state var
        for item in characters.enumerated() {
            let textSize = textSize(item.element)
            characters[item.offset].textSize = textSize
        }
        
        var gridArray: [[Character]] = []
        var tempArray: [Character] = []
        
        var currentWidht: CGFloat = 0
        // 30 - horizontal padding
        let totalScreenWidht: CGFloat = UIScreen.main.bounds.width - 30
        
        for character in characters {
            currentWidht += character.textSize
            
            if currentWidht < totalScreenWidht {
                tempArray.append(character)
            } else {
                gridArray.append(tempArray)
                tempArray = []
                currentWidht = character.textSize
                tempArray.append(character)
            }
        }
        
        // checking exhaust
        if !tempArray.isEmpty {
            gridArray.append(tempArray)
        }
        
        return gridArray
    }
    
    // MARK: calculate text size
    private func textSize(_ character: Character) -> CGFloat {
        let font = UIFont.systemFont(ofSize: character.fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (character.value as String).size(withAttributes: attributes)
        
        //add horizontal paddings + hstack padding
        return size.width + (character.padding * 2) + 15
    }
    
    // MARK: Updating shuffled array
    func updateShuffledArray(_ character: Character) {
        for index in shuffledRows.indices {
            for subIndex in shuffledRows[index].indices {
                if shuffledRows[index][subIndex].id == character.id {
                    shuffledRows[index][subIndex].isShowing = true
                }
            }
        }
    }
    
    // MARK: Animate wrong dropping
    func animateView() {
        withAnimation(.interactiveSpring(
            response: 0.3,
            dampingFraction: 0.2,
            blendDuration: 0.2)) {
                animatedWrongText = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interactiveSpring(
                response: 0.3,
                dampingFraction: 0.2,
                blendDuration: 0.2)) {
                    animatedWrongText = false
            }
        }
    }
    
    // MARK: Fill/Nullify all the data
    func fillData(_ isInit: Bool = false) {
        
        characters = characters.shuffled()
        shuffledRows = generateGrid()
        characters = characters_
        rows = generateGrid()
        progress = 0
        droppedCounter = 0
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//            .preferredColorScheme(.dark)
            .previewDevice("iPhone 13")
    }
}
