import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd.MM.YYYY"
        return dateFormatter
    }()
    
    func configureCell(data: NoteEntity) {
        
        let attributedString = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: (data.noteData!))
        
        titleLabel.text = {
            var titlteText = ""
            if data.title == "" {
                titlteText = "Нет заголовка"
            } else {
                titlteText = data.title!
            }
            return titlteText
        }()
        
        dateLabel.text = dateFormatter.string(from: data.date!)
        noteLabel.text = attributedString?.string
    }
    
}
