import Granite
import GraniteUI
import SwiftUI

extension Draft: View {
    public var view: some View {
        VStack(spacing: 0) {
            HStack(spacing: .layer4) {
                VStack {
                    Spacer()
                    Text("Create")
                        .font(.title.bold())
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    Button {
                        GraniteHaptic.light.invoke()
                        createCategory()
                    } label : {
                        Image(systemName: "folder.fill.badge.plus")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, .layer2)
                }
            }
            .frame(height: 36)
            .padding(.bottom, .layer4)
            .padding(.leading, .layer4)
            .padding(.trailing, .layer4)
            Divider()
            InteractiveDragDropContainer {
                ScrollView {
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 84, maximum: 120),
                                                                 spacing: .layer4),
                                             count: Device.isMacOS ? 5 : 3),
                              alignment: .center,
                              spacing: .layer5) {
                        ForEach(service.state.categories) { model in
                            DropView(internalID: model.id) { dropInfo in
                                CategoryView(model: model,
                                             manuscriptIDs: service.state.drafts[model] ?? [],
                                             dropInfo: dropInfo)
                            }
                            .onDragViewReceived { id in
                                service.center.addToCategory.send(DraftService.AddToCategory.Meta(category: model, manuscriptID: id))
                            }
                        }
                        ForEach(service.uncategorized) { model in
                            DragView(id: model.id) { dragInfo in
                                ManuscriptView(model: model, hideMeta: dragInfo.isDragging)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)
            }
            .padding(.horizontal, .layer4)
            .padding(.top, .layer5)
        }
        .padding(.top, .layer5)
        .padding(.bottom, .layer5)
        .addGraniteSheet(modal.sheetManager, background: Color.clear)
    }
}

struct CategoryView: View {
    var model: Category
    var manuscriptIDs: [String]
    var dropInfo: DropInfo
    
    var body: some View {
        VStack(spacing: .layer2) {
            if dropInfo.isColliding == false {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 16),
                                                             spacing: 0),
                                         count: 3),
                          alignment: .leading,
                          spacing: .layer1) {
                    ForEach(manuscriptIDs, id: \.self) { model in
                        Image(systemName: "doc.text.fill")
                            .font(.title)
                    }
                }
                .padding(.layer2)
                Spacer()
                Text(model.title)
                    .font(.headline)
                    .padding(.bottom, .layer1)
            }
        }
        .frame(width: 120, height: 120)
        .background(dropInfo.isColliding ? Brand.Colors.yellow.opacity(0.2) : Brand.Colors.white.opacity(0.2))
        .overlayIf(dropInfo.isColliding) {
            VStack {
                Spacer()
                Text("Drop Here")
                    .font(.title3.bold())
                Spacer()
            }
        }
        .cornerRadius(16)
    }
}

struct ManuscriptView: View {
    var model: Manuscript
    var hideMeta: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: "doc.text.fill")
                .resizable()
                .frame(width: 64, height: 84)
            if !hideMeta {
                Text(model.title)
                    .font(.headline.bold())
                Text(model.dateCreated.asString)
                    .font(.footnote)
            }
        }
        .opacity(hideMeta ? 0.7 : 1.0)
        .frame(height: 120)
    }
}
