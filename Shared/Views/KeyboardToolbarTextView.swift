//
//  KeyboardToolbar.swift
//  Loom
//
//  Created by PEXAVC on 8/22/23.
//

#if os(iOS)
import KeyboardToolbar
import UIKit
import SwiftUI
import Granite
import GraniteUI

struct TextToolView : GenericControllerRepresentable {
    @GraniteAction<Void> var onSubmit
    @GraniteAction<Bool> var isFocused
    @GraniteAction<Void> var toggleVisibility
    
    @Binding var text: String
    @Binding var visibility: Bool
    
    var kind: Kind
    var inheritKind: Kind?
    
    init(text: Binding<String>,
         visibility: Binding<Bool> = .constant(false),
         kind: Kind = .writing,
         inheritStyle: Kind? = nil) {
        self._text = text
        self._visibility = visibility
        self.kind = kind
        self.inheritKind = inheritStyle
    }
    
    enum Kind {
        case writing
        case search
        case link
        case otp
        case standard(String)//placeholder
        case username(String)//placeholder
        case password(String)
    }
    
    func makeUIViewController(context: Context) -> KeyboardViewController {
        let controller: KeyboardViewController = .init(self.kind, inheritKind: self.inheritKind)
        controller.textView.insertText(text)
        controller.textView.delegate = context.coordinator
        controller.delegate = context.coordinator
        context.coordinator.delegate = controller
        return controller
    }
    
    func updateUIViewController(_ uiViewController: KeyboardViewController,
                                context: Context) {
        if uiViewController.textView.text.isEmpty && text.isNotEmpty {
            DispatchQueue.main.async {
                uiViewController.textView.insertText(text)
            }
        }
        uiViewController.placeholderLabel.isHidden = text.isNotEmpty
        uiViewController.isVisible = visibility
        uiViewController.setupKeyboardTools()
    }
    
    func makeCoordinator() -> Coordinator {
        .init(parent: self, text: $text)
    }
    
    class Coordinator: NSObject, UITextViewDelegate, KeyboardTextToolDelegate {
        var parent: TextToolView
        weak var delegate: KeyboardTextToolControllerDelegate?
        
        @Binding var text: String
        init(parent: TextToolView, text: Binding<String>) {
            self.parent = parent
            self._text = text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            guard let text = textView.text else { return }
            self.text = text
        }
        
        func textView(_ textView: UITextView,
                      shouldChangeTextIn range: NSRange,
                      replacementText text: String) -> Bool {
            if (text as NSString).rangeOfCharacter(from: CharacterSet.newlines).location == NSNotFound {
                
                return true
            }
            
            switch parent.kind {
            case .writing:
                return true
            default:
                parent.onSubmit.perform()
                textView.resignFirstResponder()
            }
            
            return false
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            delegate?.setPlaceholderVisibility(text.isEmpty)
            parent.isFocused.perform(false)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused.perform(true)
            
        }
        
        //KeyboardTextToolDelegate
        func commitAction() {
            parent.onSubmit.perform()
        }
        
        func toggleVisibility() {
            parent.visibility.toggle()
        }
    }
}

protocol KeyboardTextToolDelegate: AnyObject {
    func commitAction()
    func toggleVisibility()
}

protocol KeyboardTextToolControllerDelegate: AnyObject {
    func setPlaceholderVisibility(_ isVisible: Bool)
}

final class KeyboardViewController: UIViewController, KeyboardTextToolControllerDelegate {
    private let contentView = KeyboardView()
    private let keyboardToolbarView = KeyboardToolbarView()
    var textView: UITextView {
        return contentView.textView
    }
    
    let kind: TextToolView.Kind
    let inheritKind: TextToolView.Kind?
    
    weak var delegate: KeyboardTextToolDelegate?
    
    var placeholderLabel : UILabel!
    
    //States
    fileprivate var isVisible: Bool = false
    
    init(_ kind: TextToolView.Kind,
         inheritKind: TextToolView.Kind? = nil) {
        self.kind = kind
        self.inheritKind = inheritKind
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.inputAccessoryView = keyboardToolbarView
        
        let kind = inheritKind ?? self.kind
        switch kind {
        case .link:
            textView.font = .preferredFont(forTextStyle: .title3)
        case .standard, .username, .password:
            textView.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)
        default:
            break
        }
        
        placeholderLabel = UILabel()
        switch kind {
        case .standard(let placeholder),
                .password(let placeholder),
                .username(let placeholder):
            placeholderLabel.text = placeholder.localized()
        case .link:
            //TODO: placeholder
            placeholderLabel.text = "Instance URL"
        case .writing, .otp:
            break
        case .search:
            placeholderLabel.text = "MISC_SEARCH".localized()
        }
        
        switch self.kind {
        case .username:
            textView.textContentType = .username
            textView.autocorrectionType = .no
            textView.autocapitalizationType = .none
        case .password:
            textView.textContentType = .password
            textView.autocorrectionType = .no
            textView.isSecureTextEntry = true
            textView.autocapitalizationType = .none
        case .otp:
            textView.textContentType = .oneTimeCode
            textView.autocorrectionType = .no
            textView.keyboardType = .numberPad
        case .link:
            textView.textContentType = .URL
            textView.autocorrectionType = .no
            textView.autocapitalizationType = .none
        case .search:
            textView.autocorrectionType = .no
            textView.autocapitalizationType = .none
        default:
            break
        }
        
        placeholderLabel.font = textView.font
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 8, y: ((textView.font?.pointSize)! / 2) - 2)
        placeholderLabel.textColor = UIColor(Color.foreground.opacity(0.3))
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        if Device.isiPad {
            
            textView.contentInset = .init(top: .layer1,
                                          left: 0,
                                          bottom: 0,
                                          right: 0)
        } else {
            switch kind {
            case .standard,
                    .username,
                    .password:
                //TODO: customizable
                //And or fully pre-styled
                textView.contentInset = .init(top: 10,
                                              left: 12,
                                              bottom: 0,
                                              right: 12)
            case .search:
                textView.contentInset = .init(top: .layer1,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
            default:
                textView.contentInset = .init(top: 2,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
            }
        }
        
        switch kind {
        case .search:
            textView.returnKeyType = .search
        case .standard, .username, .password:
            textView.returnKeyType = .done
        default:
            break
        }
        
        setupKeyboardTools()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setPlaceholderVisibility(_ isVisible: Bool) {
        self.placeholderLabel.isHidden = isVisible == false
    }
}

//MARK: Setup KeyboardGroups
private extension KeyboardViewController {
    func setupKeyboardTools() {
        
        keyboardToolbarView.groups = [
            undoToolgroup
        ]
        
        switch kind {
        case .link:
            //keyboardToolbarView.groups.append(linkToolgroup)
            keyboardToolbarView.groups.append(actionToolgroup)
        case .otp,
                .search,
                .standard,
                .password,
                .username:
            keyboardToolbarView.groups.append(actionToolgroup)
        case .writing:
            keyboardToolbarView.groups.append(editingToolgroup)
            keyboardToolbarView.groups.append(writingActionToolgroup)
        }
        
    }
}

//MARK: Keyboard View
final class KeyboardView: UIView {
    let textView: UITextView = {
        let this = UITextView()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.font = .preferredFont(forTextStyle: .body)
        this.textColor = UIColor(Color.foreground)
        this.backgroundColor = .clear
        return this
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor(named: "background")
        addSubview(textView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

struct InsertTextKeyboardTool: KeyboardTool {
    let displayRepresentation: KeyboardToolDisplayRepresentation
    
    private let text: String
    private weak var textView: UITextInput?
    
    init(text: String, textView: UITextInput) {
        self.displayRepresentation = .text(text)
        self.text = text
        self.textView = textView
    }
    
    func performAction() {
        textView?.insertText(text)
    }
}

struct StyleTextKeyboardTool: KeyboardTool {
    let displayRepresentation: KeyboardToolDisplayRepresentation
    
    enum Kind: String {
        case bold = "**"
        case italic = "*"
        case strikethrough = "~~"
        case code = "`"
        
        var symbolName: String {
            switch self {
            case .bold:
                return "bold"
            case .italic:
                return "italic"
            case .strikethrough:
                return "strikethrough"
            case .code:
                return "chevron.left.forwardslash.chevron.right"
            }
        }
        
        func insert(_ text: String = "____") -> String {
            self.rawValue + text + self.rawValue
        }
    }
    
    private weak var textView: UITextInput?
    private var kind: Kind
    
    init(_ kind: Kind, textView: UITextInput) {
        self.displayRepresentation = .symbol(named: kind.symbolName)
        self.textView = textView
        self.kind = kind
    }
    
    func performAction() {
        if let range = textView?.selectedTextRange,
           let text = textView?.text(in: range) {
            textView?.replace(range, withText: kind.insert(text))
        } else {
            textView?.insertText(kind.insert())
        }
    }
}

struct StyleFormatKeyboardTool: KeyboardTool {
    let displayRepresentation: KeyboardToolDisplayRepresentation
    
    enum Kind: String {
        case h1
        case h2
        case h3
        case h4
        case quote
        case table
        case link
        case image
        
        var symbolValue: String {
            switch self {
            case .h1:
                return "#"
            case .h2:
                return "##"
            case .h3:
                return "###"
            case .h4:
                return "####"
            case .quote:
                return ">"
            case .table:
                return "| Table  |\n|:----:|\n|Row 1|\n|Row 2|"
            default:
                return ""
                
            }
        }
        
        func insert(_ text: String = "") -> String {
            switch self {
            case .link:
                return "[](\(text))"
            case .image:
                return "![](\(text))"
            default:
                return self.symbolValue + " " + text
            }
            
        }
    }
    
    private weak var textView: UITextInput?
    private var kind: Kind
    
    init(_ kind: Kind, textView: UITextInput) {
        switch kind {
        case .quote:
            self.displayRepresentation = .symbol(named: "quote.closing")
        case .table:
            self.displayRepresentation = .symbol(named: "tablecells")
        case .link:
            self.displayRepresentation = .symbol(named: "link")
        case .image:
            self.displayRepresentation = .symbol(named: "photo")
        default:
            self.displayRepresentation = .text(kind.rawValue.capitalized)
        }
        self.textView = textView
        self.kind = kind
    }
    
    func performAction() {
        if let range = textView?.selectedTextRange,
           let text = textView?.text(in: range) {
            textView?.replace(range, withText: kind.insert(text))
        } else {
            textView?.insertText(kind.insert())
        }
    }
}

//MARK: Toolgroups

extension KeyboardViewController {
    var undoToolgroup: KeyboardToolGroup {
        let canUndo = textView.undoManager?.canUndo ?? false
        let canRedo = textView.undoManager?.canRedo ?? false
        return KeyboardToolGroup(items: [
            KeyboardToolGroupItem(style: .secondary, representativeTool: BlockKeyboardTool(symbolName: "arrow.uturn.backward") { [weak self] in
                self?.textView.undoManager?.undo()
                self?.setupKeyboardTools()
            }, isEnabled: canUndo),
            KeyboardToolGroupItem(style: .secondary, representativeTool: BlockKeyboardTool(symbolName: "arrow.uturn.forward") { [weak self] in
                self?.textView.undoManager?.redo()
                self?.setupKeyboardTools()
            }, isEnabled: canRedo)
        ])
    }
    
    var editingToolgroup: KeyboardToolGroup {
        KeyboardToolGroup(items: [
            KeyboardToolGroupItem(representativeTool: StyleTextKeyboardTool(.bold, textView: textView), tools: [
                StyleTextKeyboardTool(.bold, textView: textView),
                StyleTextKeyboardTool(.italic, textView: textView),
                StyleTextKeyboardTool(.strikethrough, textView: textView)
            ]),
            KeyboardToolGroupItem(representativeTool: StyleFormatKeyboardTool(.h1, textView: textView), tools: [
                StyleFormatKeyboardTool(.h1, textView: textView),
                StyleFormatKeyboardTool(.h2, textView: textView),
                StyleFormatKeyboardTool(.h3, textView: textView),
                StyleFormatKeyboardTool(.h4, textView: textView)
            ]),
            KeyboardToolGroupItem(representativeTool: StyleFormatKeyboardTool(.quote, textView: textView), tools: [
                StyleFormatKeyboardTool(.quote, textView: textView),
                StyleTextKeyboardTool(.code, textView: textView),
                StyleFormatKeyboardTool(.link, textView: textView),
                StyleFormatKeyboardTool(.image, textView: textView),
                //StyleFormatKeyboardTool(.table, textView: textView),
            ]),
            KeyboardToolGroupItem(representativeTool: InsertTextKeyboardTool(text: ".", textView: textView), tools: [
                InsertTextKeyboardTool(text: ".", textView: textView),
                InsertTextKeyboardTool(text: ",", textView: textView),
                InsertTextKeyboardTool(text: ":", textView: textView),
                InsertTextKeyboardTool(text: "-", textView: textView),
                InsertTextKeyboardTool(text: "!", textView: textView),
                InsertTextKeyboardTool(text: "&", textView: textView),
                InsertTextKeyboardTool(text: "|", textView: textView),
                InsertTextKeyboardTool(text: "*", textView: textView)
            ]),
            KeyboardToolGroupItem(representativeTool: InsertTextKeyboardTool(text: "#", textView: textView), tools: [
                InsertTextKeyboardTool(text: "#", textView: textView),
                InsertTextKeyboardTool(text: "\"", textView: textView),
                InsertTextKeyboardTool(text: "'", textView: textView),
                InsertTextKeyboardTool(text: "$", textView: textView),
                InsertTextKeyboardTool(text: "\\", textView: textView),
                InsertTextKeyboardTool(text: "@", textView: textView),
                InsertTextKeyboardTool(text: "%", textView: textView),
                InsertTextKeyboardTool(text: "~", textView: textView)
            ])
        ])
    }
    
    var linkToolgroup: KeyboardToolGroup {
        KeyboardToolGroup(items: [
            KeyboardToolGroupItem(representativeTool: InsertTextKeyboardTool(text: "https://", textView: textView)),
            KeyboardToolGroupItem(representativeTool: InsertTextKeyboardTool(text: ".com", textView: textView), tools: [
                InsertTextKeyboardTool(text: ".com", textView: textView),
                InsertTextKeyboardTool(text: ".ee", textView: textView),
                InsertTextKeyboardTool(text: ".ml", textView: textView),
                InsertTextKeyboardTool(text: ".net", textView: textView),
                InsertTextKeyboardTool(text: ".world", textView: textView)
            ])
        ])
    }
    
    var writingActionToolgroup: KeyboardToolGroup {
        let item = KeyboardToolGroupItem(style: .secondary, representativeTool: BlockKeyboardTool(symbolName: "scroll\(isVisible ? ".fill" : "")") { [weak self] in
            GraniteHaptic.light.invoke()
            self?.delegate?.toggleVisibility()
        })
        
        return KeyboardToolGroup(items: [
            item,
            KeyboardToolGroupItem(style: .secondary, representativeTool: BlockKeyboardTool(symbolName: "keyboard.chevron.compact.down") { [weak self] in
                GraniteHaptic.light.invoke()
                self?.textView.resignFirstResponder()
            })
        ])
    }
    
    var actionToolgroup: KeyboardToolGroup {
        KeyboardToolGroup(items: [
            KeyboardToolGroupItem(style: .secondary, representativeTool: BlockKeyboardTool(symbolName: "keyboard.chevron.compact.down") { [weak self] in
                GraniteHaptic.light.invoke()
                self?.textView.resignFirstResponder()
            })
        ])
    }
}

#endif
