import UIKit
import CoreData

protocol NotesDelegate {
    func reloadData()
}

class NoteViewController: UIViewController {
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var colorsButtonsStackView: UIStackView!
    @IBOutlet weak var fontSizesButtonsStackView: UIStackView!
    @IBOutlet weak var fontsButtonsStackView: UIStackView!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var boldButton: UIButton!
    @IBOutlet weak var italicsButton: UIButton!
    
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var fontSizeButton: UIButton!
    @IBOutlet weak var fontColorButton: UIButton!
    
    @IBOutlet weak var size8Button: UIButton!
    @IBOutlet weak var size12Button: UIButton!
    @IBOutlet weak var size18Button: UIButton!
    @IBOutlet weak var size24Button: UIButton!
    
    @IBOutlet weak var helveticaButton: UIButton!
    @IBOutlet weak var menloButton: UIButton!
    @IBOutlet weak var optimaButton: UIButton!
    @IBOutlet weak var palatinoButton: UIButton!
    
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var indigoButton: UIButton!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    var boldOn = false
    var italicsOn = false
    var fontName: String = ""
    var fontSize: CGFloat = 0.0
    var fontColor: UIColor = .black
    var noteEditing: Bool = false
    var attributes: [NSAttributedString.Key: Any] = [:]
    
    var noteEntity: NoteEntity?
    var noteIndex: Int = 0
    
    var delegate: NotesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardNotifications()
        componentsSetup()
        loadingNote()
        
        noteTextView.delegate = self
    
        changeFontAttributes()
        
    }
    
    deinit {
        removeNotifications()
    }
    
    //Загрузка заметки если редактируем существующую
    func loadingNote() {
        if noteEntity != nil {
            let attributedString = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: (noteEntity!.noteData!))
            noteTextView.attributedText = attributedString
            titleTextField.text = noteEntity!.title
        }
    }
    
    //Сохранение новой / изменение существующей заметки
    func saveNote() {
        
        let noteAttributedText = noteTextView.attributedText
        let data = try! NSKeyedArchiver.archivedData(withRootObject: noteAttributedText as Any, requiringSecureCoding: false)
        let title = titleTextField.text ?? ""
        
        if !noteEditing {
            NotesCoreData.shared.noteSaver(title: title, body: data)
        } else {
            NotesCoreData.shared.noteEditor(title: title, body: data, noteIndex: self.noteIndex)
        }
    }
    
    //Done
    @IBAction func doneButton(_ sender: Any) {
        saveNote()
        self.dismiss(animated: true, completion: nil)
        self.delegate?.reloadData()
    }
    
    //Кнопка возврата к заметкам
    @IBAction func backToNotesButton(_ sender: Any) {
        saveNote()
        self.dismiss(animated: true, completion: nil)
        self.delegate?.reloadData()
    }
    
    //Включение / отключение жирного и курсива
    @IBAction func switchBoldAndItalics(_ sender: Any) {
        
        let button = sender as! UIButton
        
        switch button.tag {
        case 0:
            
            boldOn = !boldOn
            
            if boldOn {
                boldButton.backgroundColor = .systemYellow
            } else {
                boldButton.backgroundColor = .darkGray
            }
            
        case 1:
            
            italicsOn = !italicsOn
            
            if italicsOn {
                italicsButton.backgroundColor = .systemYellow
            } else {
                italicsButton.backgroundColor = .darkGray
            }
            
        default: print("Unknown button")
            
        }
        
        self.changeFontAttributes()
        
    }
    
    //Показ дополнительных кнопок Шрифт, Размер, Цвет
    @IBAction func openAdditionalButtons(_ sender: Any) {
        
        let button = sender as! UIButton
        
        switch button.tag {
        case 0:
            fontsButtonsStackView.isHidden = false
            fontSizesButtonsStackView.isHidden = true
            colorsButtonsStackView.isHidden = true
        case 1:
            fontsButtonsStackView.isHidden = true
            fontSizesButtonsStackView.isHidden = false
            colorsButtonsStackView.isHidden = true
        case 2:
            fontsButtonsStackView.isHidden = true
            fontSizesButtonsStackView.isHidden = true
            colorsButtonsStackView.isHidden = false
        default: print("Unknown button")
        }
        
        self.view.layoutIfNeeded()
    }
    
    //Изменение параметров шрифта
    @IBAction func changeFontParameters(_ sender: Any) {
        
        let button = sender as! UIButton
        
        switch button.tag {
        case 0...3:
            guard let doubleButtonTitle = NumberFormatter().number(from: (button.titleLabel?.text)!) else { return }
            fontSize = CGFloat(truncating: doubleButtonTitle)
            fontSizesButtonsStackView.isHidden = true
        case 4:
            fontName = "Helvetica Neue"
            fontsButtonsStackView.isHidden = true
        case 5:
            fontName = "Menlo Regular"
            fontsButtonsStackView.isHidden = true
        case 6:
            fontName = "Optima Regular"
            fontsButtonsStackView.isHidden = true
        case 7:
            fontName = "Palatino"
            fontsButtonsStackView.isHidden = true
        case 8...11:
            guard let buttonColor = button.backgroundColor else { return }
            fontColor = buttonColor
            colorsButtonsStackView.isHidden = true
            buttonsStackView.isHidden = false
        default: print("Unknown button")
        }
        
        changeFontAttributes()
        
    }
    
    //Изменение аттрибутов шрифта
    func changeFontAttributes() {
        
        if boldOn && italicsOn {
            self.attributes = [.font: UIFont(name: self.fontName, size: self.fontSize)!.bold().italic() as Any,
                               .foregroundColor: self.fontColor
            ]
        }
        
        if !boldOn && italicsOn {
            self.attributes = [.font: UIFont(name: self.fontName, size: self.fontSize)!.italic().removeBold() as Any,
                               .foregroundColor: self.fontColor]
        }
        
        if boldOn && !italicsOn {
            self.attributes = [.font: UIFont(name: self.fontName, size: self.fontSize)!.removeItalic().bold() as Any,
                               .foregroundColor: self.fontColor]
        }
        
        if !boldOn && !italicsOn {
            self.attributes = [.font: UIFont(name: self.fontName, size: self.fontSize)!.removeItalic().removeBold() as Any,
                               .foregroundColor: self.fontColor]
        }
        
    }
    
    //Настройки UI
    func componentsSetup() {
        
        fontName = "Helvetica Neue"
        fontSize = 20.0
        fontColor = .black
        
        noteTextView.textContainer.lineFragmentPadding = 0
        
        hideAllButtonsStacks()
        buttonsStackView.alpha = 0
        
        boldButton.roundCorners([.bottomLeft, .topLeft], radius: 10)
        fontColorButton.roundCorners([.bottomRight, .topRight], radius: 10)
        
        blackButton.roundCorners([.bottomLeft, .topLeft], radius: 10)
        indigoButton.roundCorners([.bottomRight, .topRight], radius: 10)
        
        helveticaButton.roundCorners([.bottomLeft, .topLeft], radius: 10)
        palatinoButton.roundCorners([.bottomRight, .topRight], radius: 10)
        
        size8Button.roundCorners([.bottomLeft, .topLeft], radius: 10)
        size24Button.roundCorners([.bottomRight, .topRight], radius: 10)
        
    }
    
    //Спрятать все кнопки
    func hideAllButtonsStacks() {
        colorsButtonsStackView.isHidden = true
        fontSizesButtonsStackView.isHidden = true
        fontsButtonsStackView.isHidden = true
        buttonsStackView.isHidden = true
    }
    
    //Подписка на уведомления клавиатуры
    func keyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //Отписка от уведомлений клавиатуры
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //Показ клавиатуры
    @objc func keyboardWillShow(_ notification: Notification) {
        
        let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        
        let keyboardHeight = keyboardSize.height
        
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {return}
        
        let bottomSafeArea = window.safeAreaInsets.bottom
        
        buttonsStackView.isHidden = false
        
        bottomConstraint.constant = keyboardHeight - bottomConstraint.constant - bottomSafeArea
        
        UIView.animate(withDuration: 0.1) {
            self.buttonsStackView.alpha = 1
        }
        
        self.view.layoutIfNeeded()
        
    }
    
    //Скрытие клавиатуры
    @objc func keyboardWillHide() {
        hideAllButtonsStacks()
        bottomConstraint.constant = 0
        buttonsStackView.alpha = 0
        self.view.layoutIfNeeded()
    }
    
}

extension NoteViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.noteTextView.typingAttributes = self.attributes
        return true
    }
    
}
