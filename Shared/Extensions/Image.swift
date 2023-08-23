//
//  Image.swift
//  Loom
//
//  Created by PEXAVC on 7/23/23.
//

import Foundation

#if os(iOS)
import UIKit

extension UIImage{
    func normalizedImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    func writeToURL(_ stringRep : String = "linenandsole.png") -> URL?{
        
        let exportPath : NSString = NSTemporaryDirectory().appending(stringRep) as NSString
        let assetURL = URL(fileURLWithPath: exportPath as String)
        
        do {
            if let pngData = self.png {
                try pngData.write(to: assetURL)
                
                return assetURL
            }
        }catch{
            print("[UIImage] {Extension} There was an error in exporting the image data.")
        }
        
        return nil
    }
    
    //MARK: -- Main rotation cropping interaction
    
    //Crop with rotation
    
    func cropWithRotation(of: CGFloat, to: CGRect) -> UIImage{
        //opposite direction for accurate mapping before context drawing
        var rad = ((360-of)*CGFloat(Double.pi/180))
        if of < 0{
            rad = ((360+of)*CGFloat(Double.pi/180))
        }
        
        let offsetX = (size.width/2)-(to.origin.x + (to.width/2))
        let offsetY = (size.height/2)-(to.origin.y + (to.height/2))
        
        UIGraphicsBeginImageContext(CGSize(width: to.width, height: to.height))
        let bitmap = UIGraphicsGetCurrentContext()
        
        bitmap?.translateBy(x: to.width / 2.0, y: to.height / 2.0)
        
        bitmap?.rotate(by: rad)
        bitmap?.scaleBy(x: 1.0, y: -1.0)
        
        bitmap?.draw(self.cgImage!, in: CGRect(x: -(size.width/2)+offsetX, y: -(size.height/2)-offsetY, width: size.width, height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    
        return UIImage(cgImage: newImage!.cgImage!)
    }
    
    func resize(targetSize: CGSize) -> UIImage {
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //Mark: -- metadata
    
    var metadata: NSDictionary? {
        if let imageData = self.jpg {
            if let imageSource = CGImageSourceCreateWithData(imageData as NSData, nil) {
                guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) else{
                    return nil
                }
                
                return imageProperties
            }
        }
        
        return nil
    }
    
    //Mark: -- retrieves PNG data with correct orientation
    
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    var png: Data? {
        guard let flattened = flattened else { return nil }
        return flattened.pngData()
    }
    
    var jpg: Data? {
        guard let flattened = flattened else { return nil }
        return flattened.jpegData(compressionQuality: 10)
    }
    
    var jpg60: Data? {
        guard let flattened = flattened else { return nil }
        return flattened.jpegData(compressionQuality: 6)
    }
    
    var flattened: UIImage? {
        if (imageOrientation == .up) { return self }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.rotated(by: .pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0.0, y: size.height)
            transform = transform.rotated(by: -.pi / 2.0)
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        default:
            break
        }
        
        guard let cgImg = cgImage else { return nil }
        
        if let context = CGContext(data: nil,
                                   width: Int(size.width), height: Int(size.height),
                                   bitsPerComponent: cgImg.bitsPerComponent,
                                   bytesPerRow: 0, space: cgImg.colorSpace!,
                                   bitmapInfo: cgImg.bitmapInfo.rawValue) {
            
            context.concatenate(transform)
            
            if imageOrientation == .left || imageOrientation == .leftMirrored ||
                imageOrientation == .right || imageOrientation == .rightMirrored {
                context.draw(cgImg, in: CGRect(x: 0.0, y: 0.0, width: size.height, height: size.width))
            } else {
                context.draw(cgImg, in: CGRect(x: 0.0 , y: 0.0, width: size.width, height: size.height))
            }
            
            if let contextImage = context.makeImage() {
                return UIImage(cgImage: contextImage)
            }
            
        }
        
        return nil
    }
    
    //Mark: -- Error handling
    
    var isPanorama: Bool {
        let smallest = min(self.size.width, self.size.height)
        let largest = max(self.size.width, self.size.height)
        let ratio = largest/smallest
        if ((ratio >= CGFloat(4/1)) || (ratio >= CGFloat(10/1))) {
            
            return true
        }else{
            return false
        }
    }
    
}
#endif
