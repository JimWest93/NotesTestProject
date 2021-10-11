import Foundation
import UIKit

public extension UIFont {
    
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let symTraits = fontDescriptor.symbolicTraits
        let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(arrayLiteral: symTraits, traits))
        return UIFont(descriptor: descriptor!, size: 0) 
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
    func withoutTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var symTraits = fontDescriptor.symbolicTraits
        symTraits.remove([traits])
        let fontDescriptorVar = fontDescriptor.withSymbolicTraits(symTraits)
        return UIFont(descriptor: fontDescriptorVar!, size: 0)
    }
    
    func removeBold() -> UIFont {
        return withoutTraits(traits: .traitBold)
    }
    
    func removeItalic() -> UIFont {
        return withoutTraits(traits: .traitItalic)
    }
    
}
