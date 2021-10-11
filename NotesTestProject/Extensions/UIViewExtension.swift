import Foundation
import UIKit

public extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.frame = self.bounds
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
    
}
