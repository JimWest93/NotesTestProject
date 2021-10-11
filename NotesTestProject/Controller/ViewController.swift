import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var notesTableView: UITableView!
    
    var notes: [NoteEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        notesTableView.delegate = self
        notesTableView.dataSource = self
        firstNote()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        notes = NotesCoreData.shared.notesData()
    }
    
    //Кнопка добавления новой заметки
    @IBAction func addNote(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "noteViewController") as? NoteViewController else {return}
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        vc.noteEditing = false
        present(vc, animated: true, completion: nil)
    }
    
    //Добавление первых заметок
    func firstNote() {
        
        if NotesCoreData.shared.notesData().isEmpty {
            
            let firstNote = NSAttributedString(string: "Веселов Валерий", attributes: [.font: UIFont(name: "Helvetica Neue", size: 20)! as Any,
                                                                                       .foregroundColor: UIColor.systemGreen])
            let firstNoteData = try! NSKeyedArchiver.archivedData(withRootObject: firstNote as Any, requiringSecureCoding: false)
            NotesCoreData.shared.noteSaver(title: "Хочу к вам на курс! :)", body: firstNoteData)
            
            let secondNote = NSAttributedString(string: """
                                                *Заметка удаляется свайпом влево
                                                *Можно менять шрифт
                                                *Устанавливать размер шрифта
                                                *Менять цвет текста
                                                *Делать шрифт жирным и курсивным
                                                """,
                                                attributes: [.font: UIFont(name: "Helvetica Neue", size: 20)! as Any,
                                                             .foregroundColor: UIColor.systemIndigo])
            let secondNoteData = try! NSKeyedArchiver.archivedData(withRootObject: secondNote as Any, requiringSecureCoding: false)
            NotesCoreData.shared.noteSaver(title: "О приложении", body: secondNoteData)
        }
        
        notesTableView.reloadData()
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! NoteTableViewCell
        cell.configureCell(data: notes[indexPath.row])
        return cell
    }
    
    //Удаление по свайпу
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let context = NotesCoreData.shared.context()
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, boolValue) in
            
            let note = self.notes[indexPath.row]
            
            context.delete(note)
            
            do {
                
                try context.save()
                self.notes.remove(at: indexPath.row)
                self.notesTableView.deleteRows(at: [indexPath], with: .automatic)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeActions
        
    }
    
    //Переход к изменению заметки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "noteViewController") as? NoteViewController else {return}
        vc.modalPresentationStyle = .fullScreen
        vc.noteEditing = true
        vc.noteIndex = indexPath.row
        vc.noteEntity = notes[indexPath.row]
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension ViewController: NotesDelegate {
    func reloadData() {
        notes = NotesCoreData.shared.notesData()
        self.notesTableView.reloadData()
    }
}
