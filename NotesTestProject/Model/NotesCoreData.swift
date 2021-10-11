import Foundation
import CoreData
import UIKit

class NotesCoreData {
    
    static var shared: NotesCoreData = {
        let instance = NotesCoreData()
        return instance
    }()
    
    func context() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func noteSaver(title: String, body: Data) {
        
        let context = context()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "NoteEntity", in: context) else { return }
        
        let noteObject = NoteEntity(entity: entity, insertInto: context)
        
        noteObject.date = Date()
        noteObject.title = title
        noteObject.noteData = body
        
        do {
            
            try context.save()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    func noteEditor(title: String, body: Data, noteIndex: Int) {
        
        let context = NotesCoreData.shared.context()
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        do {
            
            let noteObject = try context.fetch(fetchRequest)[noteIndex]
            noteObject.noteData = body
            noteObject.title = title
            noteObject.date = Date()
            try context.save()
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    func notesData() -> [NoteEntity] {
        
        let context = context()
        
        var notes: [NoteEntity] = []
        
        let fetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        do {
            
            notes = try context.fetch(fetchRequest)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return notes
        
    }
    
}
