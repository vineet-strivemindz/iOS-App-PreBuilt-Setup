//
//  CustomIconFont.swift
//  BodyCloud
//
//  Created by iMac on 21/09/21.
//

import Foundation
import UIKit

public extension UIImage {
    
    /**
     This init function sets the icon to UIImage
     
     - Parameter icon: The icon for the UIImage
     - Parameter size: CGSize for the icon
     - Parameter textColor: Color for the icon
     - Parameter backgroundColor: Background color for the icon
     
     - Since: 1.0.0
     */
    convenience init(icon: FontType, size: CGSize, textColor: UIColor = .black, backgroundColor: UIColor = .clear) {
        FontLoader.loadFontIfNeeded(fontType: icon)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let fontAspectRatio: CGFloat = 1.28571429
        let fontSize = min(size.width / fontAspectRatio, size.height)
        let font = UIFont(name: icon.fontName(), size: fontSize)
        assert(font != nil, icon.errorAnnounce())
        let attributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.backgroundColor: backgroundColor, NSAttributedString.Key.paragraphStyle: paragraph]
        let lineHeight = font!.lineHeight
        let attributedString = NSAttributedString(string: icon.text!, attributes: attributes)
        UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
        attributedString.draw(in: CGRect(x: 0, y: (size.height - lineHeight) * 0.5, width: size.width, height: lineHeight))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            self.init(cgImage: image.cgImage!, scale: image.scale, orientation: image.imageOrientation)
        } else {
            self.init()
        }
    }
    
    /**
     This init function adds support for stacked icons. For details check [Stacked Icons](http://fontawesome.io/examples/#stacked)
     
     - Parameter bgIcon: Background icon of the stacked icons
     - Parameter bgTextColor: Color for the background icon
     - Parameter bgBackgroundColor: Background color for the background icon
     - Parameter topIcon: Top icon of the stacked icons
     - Parameter topTextColor: Color for the top icon
     - Parameter bgLarge: Set if the background icon should be bigger
     - Parameter size: CGSize for the UIImage
     
     - Since: 1.0.0
     */
    convenience init(bgIcon: FontType, bgTextColor: UIColor = .black, bgBackgroundColor: UIColor = .clear, topIcon: FontType, topTextColor: UIColor = .black, bgLarge: Bool? = true, size: CGSize? = nil) {
        
        FontLoader.loadFontIfNeeded(fontType: bgIcon)
        FontLoader.loadFontIfNeeded(fontType: topIcon)
        
        let bgSize: CGSize!
        let topSize: CGSize!
        let bgRect: CGRect!
        let topRect: CGRect!
        
        if bgLarge! {
            topSize = size ?? CGSize(width: 30, height: 30)
            bgSize = CGSize(width: 2 * topSize.width, height: 2 * topSize.height)
            
        } else {
            
            bgSize = size ?? CGSize(width: 30, height: 30)
            topSize = CGSize(width: 2 * bgSize.width, height: 2 * bgSize.height)
        }
        
        let bgImage = UIImage.init(icon: bgIcon, size: bgSize, textColor: bgTextColor)
        let topImage = UIImage.init(icon: topIcon, size: topSize, textColor: topTextColor)
        
        if bgLarge! {
            bgRect = CGRect(x: 0, y: 0, width: bgSize.width, height: bgSize.height)
            topRect = CGRect(x: topSize.width/2, y: topSize.height/2, width: topSize.width, height: topSize.height)
            UIGraphicsBeginImageContextWithOptions(bgImage.size, false, 0.0)
            
        } else {
            topRect = CGRect(x: 0, y: 0, width: topSize.width, height: topSize.height)
            bgRect = CGRect(x: bgSize.width/2, y: bgSize.height/2, width: bgSize.width, height: bgSize.height)
            UIGraphicsBeginImageContextWithOptions(topImage.size, false, 0.0)
            
        }
        
        bgImage.draw(in: bgRect)
        topImage.draw(in: topRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            self.init(cgImage: image.cgImage!, scale: image.scale, orientation: image.imageOrientation)
        } else {
            self.init()
        }
    }
}

@available(iOS 13.0, *)
public extension UIImageView {
    
    /**
     This function sets the icon to UIImageView
     
     - Parameter icon: The icon for the UIImageView
     - Parameter textColor: Color for the icon
     - Parameter backgroundColor: Background color for the icon
     - Parameter size: CGSize for the UIImage
     
     - Since: 1.0.0
     */
    func setIcon(icon: FontType, textColor: UIColor = .black, backgroundColor: UIColor = .clear, size: CGSize? = nil) {
        self.image?.withTintColor(.white)
        self.image = UIImage(icon: icon, size: size ?? frame.size, textColor: textColor, backgroundColor: backgroundColor)
    }
}

public extension UILabel {
    
    /**
     This function sets the icon to UILabel
     
     - Parameter icon: The icon for the UILabel
     - Parameter iconSize: Size of the icon
     - Parameter textColor: Color for the icon
     - Parameter backgroundColor: Background color for the icon
     
     - Since: 1.0.0
     */
    func setIcon(icon: FontType, iconSize: CGFloat, color: UIColor = .black, bgColor: UIColor = .clear) {
        self.setIcons(prefixText: "", prefixTextColor: UIColor.clear, prefixTextFont: self.font, icons: [icon], iconsSize: iconSize, iconsColor: color, bgColor: bgColor, postfixText: "", postfixTextColor: UIColor.clear, postfixTextFont: self.font)
    }
    
    
    /**
     This function sets the icons to UILabel
     
     - Parameter icons: The icons array for the UILabel
     - Parameter iconSize: Size of all icons
     - Parameter textColor: Color for all icons
     - Parameter backgroundColor: Background color for all icon
     
     - Since: 1.1.0
     */
    fileprivate func setIcons(prefixText: String, prefixTextColor: UIColor, prefixTextFont: UIFont, icons: [FontType], iconsSize: CGFloat, iconsColor: UIColor, bgColor: UIColor, postfixText: String, postfixTextColor: UIColor, postfixTextFont: UIFont) {
        self.text = nil
        
        backgroundColor = bgColor
        textAlignment = .left
        attributedText = getAttributedString(prefixText: prefixText, prefixTextColor: prefixTextColor, prefixTextFont: prefixTextFont, icons: icons, iconsSize: iconsSize, iconsColor: iconsColor, postfixText: postfixText, postfixTextColor: postfixTextColor, postfixTextFont: postfixTextFont)
    }
    
    func setIcons(prefixText: String? = nil, prefixTextFont: UIFont? = nil, prefixTextColor: UIColor? = nil, icons: [FontType], iconColor: UIColor? = nil, postfixText: String? = nil, postfixTextFont: UIFont? = nil, postfixTextColor: UIColor? = nil, iconSize: CGFloat? = nil, bgColor: UIColor? = nil) {
        self.setIcons(prefixText: prefixText ?? "", prefixTextColor: prefixTextColor ?? self.textColor, prefixTextFont: prefixTextFont ?? self.font, icons: icons, iconsSize: iconSize ?? self.font.pointSize, iconsColor: iconColor ?? self.textColor, bgColor: bgColor ?? UIColor.clear, postfixText: postfixText ?? "", postfixTextColor: postfixTextColor ?? self.textColor, postfixTextFont: postfixTextFont ?? self.font)
    }
    
    
    /**
     This function sets the icon to UILabel with text around it with different colors
     
     - Parameter prefixText: The text before the icon
     - Parameter prefixTextColor: The color for the text before the icon
     - Parameter icon: The icon
     - Parameter iconColor: Color for the icon
     - Parameter postfixText: The text after the icon
     - Parameter postfixTextColor: The color for the text after the icon
     - Parameter size: Size of the text
     - Parameter iconSize: Size of the icon
     
     - Since: 1.0.0
     */
    func setIcon(prefixText: String, prefixTextColor: UIColor = .black, icon: FontType?, iconColor: UIColor = .black, postfixText: String, postfixTextColor: UIColor = .black, size: CGFloat?, iconSize: CGFloat? = nil) {
        let textFont = self.font.withSize(size ?? self.font.pointSize)
        self.setIcons(prefixText: prefixText, prefixTextColor: prefixTextColor, prefixTextFont: textFont, icons: icon == nil ? [] : [icon!], iconsSize: iconSize ?? self.font.pointSize, iconsColor: iconColor, bgColor: UIColor.clear, postfixText: postfixText, postfixTextColor: postfixTextColor, postfixTextFont: textFont)
    }
    
    
    /**
     This function sets the icon to UILabel with text around it with different fonts & colors
     
     - Parameter prefixText: The text before the icon
     - Parameter prefixTextFont: The font for the text before the icon
     - Parameter prefixTextColor: The color for the text before the icon
     - Parameter icon: The icon
     - Parameter iconColor: Color for the icon
     - Parameter postfixText: The text after the icon
     - Parameter postfixTextFont: The font for the text after the icon
     - Parameter postfixTextColor: The color for the text after the icon
     - Parameter iconSize: Size of the icon
     
     - Since: 1.0.0
     */
    func setIcon(prefixText: String, prefixTextFont: UIFont, prefixTextColor: UIColor = .black, icon: FontType?, iconColor: UIColor = .black, postfixText: String, postfixTextFont: UIFont, postfixTextColor: UIColor = .black, iconSize: CGFloat? = nil) {
        self.setIcons(prefixText: prefixText, prefixTextColor: prefixTextColor, prefixTextFont: prefixTextFont, icons: icon == nil ? [] : [icon!], iconsSize: iconSize ?? self.font.pointSize, iconsColor: iconColor, bgColor: UIColor.clear, postfixText: postfixText, postfixTextColor: postfixTextColor, postfixTextFont: prefixTextFont)
        
    }
}

public extension UIButton {
    
    fileprivate func setIcons(prefixText: String, prefixTextColor: UIColor, prefixTextFont: UIFont, icons: [FontType], iconsSize: CGFloat, iconsColor: UIColor, bgColor: UIColor, postfixText: String, postfixTextColor: UIColor, postfixTextFont: UIFont, forState state: UIControl.State) {
        guard let titleLabel = self.titleLabel else { return }
        let attributedText = getAttributedString(prefixText: prefixText, prefixTextColor: prefixTextColor, prefixTextFont: prefixTextFont, icons: icons, iconsSize: iconsSize, iconsColor: iconsColor, postfixText: postfixText, postfixTextColor: postfixTextColor, postfixTextFont: postfixTextFont)
        self.setAttributedTitle(attributedText, for: state)
        titleLabel.textAlignment = .center
        self.backgroundColor = bgColor
    }
    
    func setIcons(prefixText: String? = nil, prefixTextFont: UIFont? = nil, prefixTextColor: UIColor? = nil, icons: [FontType], iconColor: UIColor? = nil, postfixText: String? = nil, postfixTextFont: UIFont? = nil, postfixTextColor: UIColor? = nil, iconSize: CGFloat? = nil, bgColor: UIColor? = nil, forState state: UIControl.State) {
        guard let titleLabel = self.titleLabel else { return }
        self.setIcons(prefixText: prefixText ?? "", prefixTextColor: prefixTextColor ?? titleLabel.textColor, prefixTextFont: prefixTextFont ?? titleLabel.font, icons: icons, iconsSize: iconSize ?? titleLabel.font.pointSize, iconsColor: iconColor ?? titleLabel.textColor, bgColor: bgColor ?? self.backgroundColor ?? UIColor.clear, postfixText: postfixText ?? "", postfixTextColor: postfixTextColor ?? titleLabel.textColor, postfixTextFont: postfixTextFont ?? titleLabel.font, forState: state)
    }
    
    /**
     This function sets the icon to UIButton
     
     - Parameter icon: The icon for the UIButton
     - Parameter iconSize: Size of the icon
     - Parameter color: Color for the icon
     - Parameter backgroundColor: Background color for the UIButton
     - Parameter forState: Control state of the UIButton
     
     - Since: 1.1
     */
    func setIcon(icon: FontType, iconSize: CGFloat? = nil, color: UIColor = .black, backgroundColor: UIColor = .clear, forState state: UIControl.State) {
        self.setIcons(icons: [icon], iconColor: color, iconSize: iconSize, bgColor: backgroundColor, forState: state)
    }
    
    
    /**
     This function sets the icon to UIButton with text around it with different colors
     
     - Parameter prefixText: The text before the icon
     - Parameter prefixTextColor: The color for the text before the icon
     - Parameter icon: The icon
     - Parameter iconColor: Color for the icon
     - Parameter postfixText: The text after the icon
     - Parameter postfixTextColor: The color for the text after the icon
     - Parameter backgroundColor: Background color for the UIButton
     - Parameter forState: Control state of the UIButton
     - Parameter textSize: Size of the text
     - Parameter iconSize: Size of the icon
     
     - Since: 1.1
     */
    func setIcon(prefixText: String, prefixTextColor: UIColor = .black, icon: FontType, iconColor: UIColor = .black, postfixText: String, postfixTextColor: UIColor = .black, backgroundColor: UIColor = .clear, forState state: UIControl.State, textSize: CGFloat? = nil, iconSize: CGFloat? = nil) {
        guard let titleLabel = self.titleLabel else { return }
        let textFont = titleLabel.font.withSize(textSize ?? titleLabel.font.pointSize)
        self.setIcons(prefixText: prefixText, prefixTextFont: textFont, prefixTextColor: prefixTextColor, icons: [icon], iconColor: iconColor, postfixText: postfixText, postfixTextFont: textFont, postfixTextColor: postfixTextColor, iconSize: iconSize, bgColor: backgroundColor, forState: state)
    }
    
    
    
    
    /**
     This function sets the icon to UIButton with text around it with different fonts & colors
     
     - Parameter prefixText: The text before the icon
     - Parameter prefixTextFont: The font for the text before the icon
     - Parameter prefixTextColor: The color for the text before the icon
     - Parameter icon: The icon
     - Parameter iconColor: Color for the icon
     - Parameter postfixText: The text after the icon
     - Parameter postfixTextFont: The font for the text after the icon
     - Parameter postfixTextColor: The color for the text after the icon
     - Parameter backgroundColor: Background color for the UIButton
     - Parameter forState: Control state of the UIButton
     - Parameter iconSize: Size of the icon
     
     - Since: 1.1
     */
    func setIcon(prefixText: String, prefixTextFont: UIFont, prefixTextColor: UIColor = .black, icon: FontType?, iconColor: UIColor = .black, postfixText: String, postfixTextFont: UIFont, postfixTextColor: UIColor = .black, backgroundColor: UIColor = .clear, forState state: UIControl.State, iconSize: CGFloat? = nil) {
        
        self.setIcons(prefixText: prefixText, prefixTextFont: prefixTextFont, prefixTextColor: prefixTextColor, icons: icon == nil ? [] : [icon!], iconColor: iconColor, postfixText: postfixText, postfixTextFont: postfixTextFont, postfixTextColor: postfixTextColor, iconSize: iconSize, bgColor: backgroundColor, forState: state)
    }
    
    
    /**
     This function sets the icon to UIButton with title below it, with different colors
     
     - Parameter icon: The icon
     - Parameter iconColor: Color for the icon
     - Parameter title: The title
     - Parameter titleColor: Color for the title
     - Parameter backgroundColor: Background color for the button
     - Parameter borderSize: Border size for the button
     - Parameter borderColor: Border color for the button
     - Parameter forState: Control state of the UIButton
     
     - Since: 1.1
     */
    func setIcon(icon: FontType, iconColor: UIColor = .black, title: String, titleColor: UIColor = .black, backgroundColor: UIColor = .clear, borderSize: CGFloat = 1, borderColor: UIColor = .clear, forState state: UIControl.State) {
        
        let height = frame.size.height
        let width = frame.size.width
        let gap : CGFloat = 5
        let textHeight : CGFloat = 15
        
        let size1 = width - (borderSize * 2 + gap * 2)
        let size2 = height - (borderSize * 2 + gap * 3 + textHeight)
        let imageOrigin : CGFloat = borderSize + gap
        let textTop : CGFloat = imageOrigin + size2 + gap
        let textBottom : CGFloat = borderSize + gap
        let imageBottom : CGFloat = textBottom + textHeight + gap
        
        let image = UIImage.init(icon: icon, size: CGSize(width: size1, height: size2), textColor: iconColor, backgroundColor: backgroundColor)
        imageEdgeInsets = UIEdgeInsets(top: imageOrigin, left: imageOrigin, bottom: imageBottom, right: imageOrigin)
        titleEdgeInsets = UIEdgeInsets(top: textTop, left: -image.size.width, bottom: textBottom, right: 0.0)
        
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderSize
        setImage(image, for: state)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.1
        setTitle(title, for: state)
        setTitleColor(titleColor, for: state)
        self.backgroundColor = backgroundColor
    }
    
    
    /**
     This function sets the icon to UIButton with title (custom font) below it, with different colors
     
     - Parameter icon: The icon
     - Parameter iconColor: Color for the icon
     - Parameter title: The title
     - Parameter titleColor: Color for the title
     - Parameter font: The font for the title below the icon
     - Parameter backgroundColor: Background color for the button
     - Parameter borderSize: Border size for the button
     - Parameter borderColor: Border color for the button
     - Parameter forState: Control state of the UIButton
     
     - Since: 1.1
     */
    func setIcon(icon: FontType, iconColor: UIColor = .black, title: String, titleColor: UIColor = .black, font: UIFont, backgroundColor: UIColor = .clear, borderSize: CGFloat = 1, borderColor: UIColor = .clear, forState state: UIControl.State) {
        
        setIcon(icon: icon, iconColor: iconColor, title: title, titleColor: titleColor, backgroundColor: backgroundColor, borderSize: borderSize, borderColor: borderColor, forState: state)
        titleLabel?.font = font
    }
    
    
    /**
     This function sets the icon to UIButton with title below it
     
     - Parameter icon: The icon
     - Parameter title: The title
     - Parameter color: Color for the icon & title
     - Parameter backgroundColor: Background color for the button
     - Parameter borderSize: Border size for the button
     - Parameter borderColor: Border color for the button
     - Parameter forState: Control state of the UIButton
     
     - Since: 1.1
     */
    func setIcon(icon: FontType, title: String, color: UIColor = .black, backgroundColor: UIColor = .clear, borderSize: CGFloat = 1, borderColor: UIColor = .clear, forState state: UIControl.State) {
        
        setIcon(icon: icon, iconColor: color, title: title, titleColor: color, backgroundColor: backgroundColor, borderSize: borderSize, borderColor: borderColor, forState: state)
    }
    
    
    /**
     This function sets the icon to UIButton with title (custom font) below it
     
     - Parameter icon: The icon
     - Parameter title: The title
     - Parameter font: The font for the title below the icon
     - Parameter color: Color for the icon & title
     - Parameter backgroundColor: Background color for the button
     - Parameter borderSize: Border size for the button
     - Parameter borderColor: Border color for the button
     - Parameter forState: Control state of the UIButton
     
     - Since: 1.1
     */
    func setIcon(icon: FontType, title: String, font: UIFont, color: UIColor = .black, backgroundColor: UIColor = .clear, borderSize: CGFloat = 1, borderColor: UIColor = .clear, forState state: UIControl.State) {
        
        setIcon(icon: icon, iconColor: color, title: title, titleColor: color, font: font, backgroundColor: backgroundColor, borderSize: borderSize, borderColor: borderColor, forState: state)
    }
}

public extension UISegmentedControl {
    
    /**
     This function sets the icon to UISegmentedControl at particular segment index
     
     - Parameter icon: The icon
     - Parameter color: Color for the icon
     - Parameter iconSize: Size of the icon
     - Parameter forSegmentAtIndex: Segment index for the icon
     
     - Since: 1.0.0
     */
    func setIcon(icon: FontType, color: UIColor = .black, iconSize: CGFloat? = nil, forSegmentAtIndex segment: Int) {
        FontLoader.loadFontIfNeeded(fontType: icon)
        let font = UIFont(name: icon.fontName(), size: iconSize ?? 23)
        assert(font != nil, icon.errorAnnounce())
        setTitleTextAttributes([NSAttributedString.Key.font: font!], for: UIControl.State.normal)
        setTitle(icon.text, forSegmentAt: segment)
        tintColor = color
    }
}

public extension UITabBarItem {
    
    /**
     This function sets the icon to UITabBarItem
     
     - Parameter icon: The icon for the UITabBarItem
     - Parameter size: CGSize for the icon
     - Parameter textColor: Color for the icon when UITabBarItem is not selected
     - Parameter backgroundColor: Background color for the icon when UITabBarItem is not selected
     - Parameter selectedTextColor: Color for the icon when UITabBarItem is selected
     - Parameter selectedBackgroundColor: Background color for the icon when UITabBarItem is selected
     
     - Since: 1.0.0
     */
    func setIcon(icon: FontType, size: CGSize? = nil, textColor: UIColor = .black, backgroundColor: UIColor = .clear, selectedTextColor: UIColor = .black, selectedBackgroundColor: UIColor = .clear) {
        
        let tabBarItemImageSize = size ?? CGSize(width: 30, height: 30)
        image = UIImage(icon: icon, size: tabBarItemImageSize, textColor: textColor, backgroundColor: backgroundColor).withRenderingMode(.alwaysOriginal)
        selectedImage = UIImage(icon: icon, size: tabBarItemImageSize, textColor: selectedTextColor, backgroundColor: selectedBackgroundColor).withRenderingMode(.alwaysOriginal)
    }
    
    
    /**
     This function supports stacked icons for UITabBarItem. For details check [Stacked Icons](http://fontawesome.io/examples/#stacked)
     
     - Parameter bgIcon: Background icon of the stacked icons
     - Parameter bgTextColor: Color for the background icon
     - Parameter selectedBgTextColor: Color for the background icon when UITabBarItem is selected
     - Parameter topIcon: Top icon of the stacked icons
     - Parameter topTextColor: Color for the top icon
     - Parameter selectedTopTextColor: Color for the top icon when UITabBarItem is selected
     - Parameter bgLarge: Set if the background icon should be bigger
     - Parameter size: CGSize for the icon
     
     - Since: 1.0.0
     */
    func setIcon(bgIcon: FontType, bgTextColor: UIColor = .black, selectedBgTextColor: UIColor = .black, topIcon: FontType, topTextColor: UIColor = .black, selectedTopTextColor: UIColor = .black, bgLarge: Bool? = true, size: CGSize? = nil) {
        
        let tabBarItemImageSize = size ?? CGSize(width: 15, height: 15)
        image = UIImage(bgIcon: bgIcon, bgTextColor: bgTextColor, bgBackgroundColor: .clear, topIcon: topIcon, topTextColor: topTextColor, bgLarge: bgLarge, size: tabBarItemImageSize).withRenderingMode(.alwaysOriginal)
        selectedImage = UIImage(bgIcon: bgIcon, bgTextColor: selectedBgTextColor, bgBackgroundColor: .clear, topIcon: topIcon, topTextColor: selectedTopTextColor, bgLarge: bgLarge, size: tabBarItemImageSize).withRenderingMode(.alwaysOriginal)
    }
}

public extension UISlider {
    
    /**
     This function sets the icon to the maximum value of UISlider
     
     - Parameter icon: The icon for the maximum value of UISlider
     - Parameter size: CGSize for the icon
     - Parameter textColor: Color for the icon
     - Parameter backgroundColor: Background color for the icon
     
     - Since: 1.0.0
     */
    func setMaximumValueIcon(icon: FontType, customSize: CGSize? = nil, textColor: UIColor = .black, backgroundColor: UIColor = .clear) {
        maximumValueImage = UIImage(icon: icon, size: customSize ?? CGSize(width: 25,height: 25), textColor: textColor, backgroundColor: backgroundColor)
    }
    
    
    /**
     This function sets the icon to the minimum value of UISlider
     
     - Parameter icon: The icon for the minimum value of UISlider
     - Parameter size: CGSize for the icon
     - Parameter textColor: Color for the icon
     - Parameter backgroundColor: Background color for the icon
     
     - Since: 1.0.0
     */
    func setMinimumValueIcon(icon: FontType, customSize: CGSize? = nil, textColor: UIColor = .black, backgroundColor: UIColor = .clear) {
        minimumValueImage = UIImage(icon: icon, size: customSize ?? CGSize(width: 25,height: 25), textColor: textColor, backgroundColor: backgroundColor)
    }
}

public extension UIBarButtonItem {
    
    /**
     This function sets the icon for UIBarButtonItem
     
     - Parameter icon: The icon for the for UIBarButtonItem
     - Parameter iconSize: Size for the icon
     - Parameter color: Color for the icon
     
     - Since: 1.0.0
     */
    func setIcon(icon: FontType, iconSize: CGFloat, color: UIColor = .black) {
        
        FontLoader.loadFontIfNeeded(fontType: icon)
        let font = UIFont(name: icon.fontName(), size: iconSize)
        assert(font != nil, icon.errorAnnounce())
        setTitleTextAttributes([NSAttributedString.Key.font: font!], for: UIControl.State.normal)
        setTitleTextAttributes([NSAttributedString.Key.font: font!], for: UIControl.State.highlighted)
        setTitleTextAttributes([NSAttributedString.Key.font: font!], for: UIControl.State.disabled)
        setTitleTextAttributes([NSAttributedString.Key.font: font!], for: UIControl.State.focused)
        title = icon.text
        tintColor = color
    }
    
    
    /**
     This function sets the icon for UIBarButtonItem using custom view
     
     - Parameter icon: The icon for the for UIBarButtonItem
     - Parameter iconSize: Size for the icon
     - Parameter color: Color for the icon
     - Parameter cgRect: CGRect for the whole icon & text
     - Parameter target: Action target
     - Parameter action: Action for the UIBarButtonItem
     
     - Since: 1.5
     */
    func setIcon(icon: FontType, iconSize: CGFloat, color: UIColor = .black, cgRect: CGRect, target: AnyObject?, action: Selector) {
        
        let highlightedColor = color.withAlphaComponent(0.4)
        
        title = nil
        let button = UIButton(frame: cgRect)
        button.setIcon(icon: icon, iconSize: iconSize, color: color, forState: UIControl.State.normal)
        button.setTitleColor(highlightedColor, for: UIControl.State.highlighted)
        button.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        
        customView = button
    }
    
    
    /**
     This function sets the icon for UIBarButtonItem with text around it with different colors
     
     - Parameter prefixText: The text before the icon
     - Parameter prefixTextColor: The color for the text before the icon
     - Parameter icon: The icon
     - Parameter iconColor: Color for the icon
     - Parameter postfixText: The text after the icon
     - Parameter postfixTextColor: The color for the text after the icon
     - Parameter cgRect: CGRect for the whole icon & text
     - Parameter size: Size of the text
     - Parameter iconSize: Size of the icon
     - Parameter target: Action target
     - Parameter action: Action for the UIBarButtonItem
     
     - Since: 1.5
     */
    func setIcon(prefixText: String, prefixTextColor: UIColor = .black, icon: FontType?, iconColor: UIColor = .black, postfixText: String, postfixTextColor: UIColor = .black, cgRect: CGRect, size: CGFloat?, iconSize: CGFloat? = nil, target: AnyObject?, action: Selector) {
        
        let prefixTextHighlightedColor = prefixTextColor.withAlphaComponent(0.4)
        let iconHighlightedColor = iconColor.withAlphaComponent(0.4)
        let postfixTextHighlightedColor = postfixTextColor.withAlphaComponent(0.4)
        
        title = nil
        let button = UIButton(frame: cgRect)
        button.setIcon(prefixText: prefixText, prefixTextColor: prefixTextColor, icon: icon!, iconColor: iconColor, postfixText: postfixText, postfixTextColor: postfixTextColor, backgroundColor: .clear, forState: UIControl.State.normal, textSize: size, iconSize: iconSize)
        button.setIcon(prefixText: prefixText, prefixTextColor: prefixTextHighlightedColor, icon: icon!, iconColor: iconHighlightedColor, postfixText: postfixText, postfixTextColor: postfixTextHighlightedColor, backgroundColor: .clear, forState: UIControl.State.highlighted, textSize: size, iconSize: iconSize)
        
        button.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        
        customView = button
    }
    
    
    /**
     This function sets the icon for UIBarButtonItem with text around it with different colors
     
     - Parameter prefixText: The text before the icon
     - Parameter prefixTextColor: The color for the text before the icon
     - Parameter prefixTextColor: The color for the text before the icon
     - Parameter icon: The icon
     - Parameter iconColor: Color for the icon
     - Parameter postfixText: The text after the icon
     - Parameter postfixTextColor: The color for the text after the icon
     - Parameter postfixTextColor: The color for the text after the icon
     - Parameter cgRect: CGRect for the whole icon & text
     - Parameter size: Size of the text
     - Parameter iconSize: Size of the icon
     - Parameter target: Action target
     - Parameter action: Action for the UIBarButtonItem
     
     - Since: 1.5
     */
    func setIcon(prefixText: String, prefixTextFont: UIFont, prefixTextColor: UIColor = .black, icon: FontType?, iconColor: UIColor = .black, postfixText: String, postfixTextFont: UIFont, postfixTextColor: UIColor = .black, cgRect: CGRect, iconSize: CGFloat? = nil, target: AnyObject?, action: Selector) {
        
        let prefixTextHighlightedColor = prefixTextColor.withAlphaComponent(0.4)
        let iconHighlightedColor = iconColor.withAlphaComponent(0.4)
        let postfixTextHighlightedColor = postfixTextColor.withAlphaComponent(0.4)
        
        title = nil
        let button = UIButton(frame: cgRect)
        button.setIcon(prefixText: prefixText, prefixTextFont: prefixTextFont, prefixTextColor: prefixTextColor, icon: icon, iconColor: iconColor, postfixText: postfixText, postfixTextFont: postfixTextFont, postfixTextColor: postfixTextColor, backgroundColor: .clear, forState: UIControl.State.normal, iconSize: iconSize)
        button.setIcon(prefixText: prefixText, prefixTextFont: prefixTextFont, prefixTextColor: prefixTextHighlightedColor, icon: icon, iconColor: iconHighlightedColor, postfixText: postfixText, postfixTextFont: postfixTextFont, postfixTextColor: postfixTextHighlightedColor, backgroundColor: .clear, forState: UIControl.State.highlighted, iconSize: iconSize)
        button.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        
        customView = button
    }
}

public extension UIStepper {
    
    /**
     This function sets the increment icon for UIStepper
     
     - Parameter icon: The icon for the for UIStepper
     - Parameter forState: Control state of the increment icon of the UIStepper
     
     - Since: 1.0.0
     */
    func setIncrementIcon(icon: FontType?, forState state: UIControl.State) {
        
        let backgroundSize = CGSize(width: 20, height: 20)
        let image = UIImage(icon: icon!, size: backgroundSize)
        setIncrementImage(image, for: state)
    }
    
    
    /**
     This function sets the decrement icon for UIStepper
     
     - Parameter icon: The icon for the for UIStepper
     - Parameter forState: Control state of the decrement icon of the UIStepper
     
     - Since: 1.0.0
     */
    func setDecrementIcon(icon: FontType?, forState state: UIControl.State) {
        
        let backgroundSize = CGSize(width: 20, height: 20)
        let image = UIImage(icon: icon!, size: backgroundSize)
        setDecrementImage(image, for: state)
    }
}

public extension UITextField {
    
    /**
     This function sets the icon for the right view of the UITextField
     
     - Parameter icon: The icon for the right view of the UITextField
     - Parameter rightViewMode: UITextFieldViewMode for the right view of the UITextField
     - Parameter textColor: Color for the icon
     - Parameter backgroundColor: Background color for the icon
     - Parameter size: CGSize for the icon
     
     - Since: 1.0.0
     */
    func setRightViewIcon(icon: FontType, rightViewMode: UITextField.ViewMode = .always, textColor: UIColor = .black, backgroundColor: UIColor = .clear, size: CGSize? = nil) {
        FontLoader.loadFontIfNeeded(fontType: icon)
        
        let image = UIImage(icon: icon, size: size ?? CGSize(width: 30, height: 30), textColor: textColor, backgroundColor: backgroundColor)
        let imageView = UIImageView.init(image: image)
        
        self.rightView = imageView
        self.rightViewMode = rightViewMode
    }
    
    
    /**
     This function sets the icon for the left view of the UITextField
     
     - Parameter icon: The icon for the left view of the UITextField
     - Parameter leftViewMode: UITextFieldViewMode for the left view of the UITextField
     - Parameter textColor: Color for the icon
     - Parameter backgroundColor: Background color for the icon
     - Parameter size: CGSize for the icon
     
     - Since: 1.0.0
     */
    func setLeftViewIcon(icon: FontType, leftViewMode: UITextField.ViewMode = .always, textColor: UIColor = .black, backgroundColor: UIColor = .clear, size: CGSize? = nil) {
        FontLoader.loadFontIfNeeded(fontType: icon)
        
        let image = UIImage(icon: icon, size: size ?? CGSize(width: 30, height: 30), textColor: textColor, backgroundColor: backgroundColor)
        let imageView = UIImageView.init(image: image)
        
        self.leftView = imageView
        self.leftViewMode = leftViewMode
    }
}

public extension UIViewController {
    
    /**
     This function sets the icon for the title of navigation bar
     
     - Parameter icon: The icon for the title of navigation bar
     - Parameter iconSize: Size of the icon
     - Parameter textColor: Color for the icon
     
     - Since: 1.0.0
     */
    func setTitleIcon(icon: FontType, iconSize: CGFloat? = nil, color: UIColor = .black) {
        let size = iconSize ?? 23
        FontLoader.loadFontIfNeeded(fontType: icon)
        let font = UIFont(name: icon.fontName(), size: size)
        assert(font != nil, icon.errorAnnounce())
        let titleAttributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: color]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = icon.text
    }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.5, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

public final class FontLoader {
    /**
     This utility function helps loading the font if not loaded already
     
     - Parameter fontType: The type of the font
     
     */
    static func loadFontIfNeeded(fontType : FontType) {
        let fileName = fontType.fileName()
        let fontName = fontType.fontName()
        
        if !loadedFontsTracker[fontName]! {
            
            guard let fontPath = Bundle(for: FontLoader.self).path(forResource: fileName, ofType: "ttf") else {
                return
            }
            
            var error: Unmanaged<CFError>?
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: fontPath)) , let provider = CGDataProvider(data: data as CFData) else {
                return
            }
            
            let font = CGFont(provider)
            CTFontManagerRegisterGraphicsFont(font!, &error)
            if error != nil {
                return
            }
            loadedFontsTracker[fontName] = true

           /* let bundle = Bundle(for: FontLoader.self)
            var fontURL: URL!
            let identifier = bundle.bundleIdentifier
            
            if (identifier?.hasPrefix("org.cocoapods"))! {
                fontURL = bundle.url(forResource: fileName, withExtension: "ttf", subdirectory: "SwiftIcons.bundle")
            } else {
                fontURL = bundle.url(forResource: fileName, withExtension: "ttf")!
            }
            
            let data = try! Data(contentsOf: fontURL)
            let provider = CGDataProvider(data: data as CFData)
            let font = CGFont(provider!)!
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
                let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
                NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
            } else {
                loadedFontsTracker[fontName] = true
            }*/
        }
    }
}

private var loadedFontsTracker: [String: Bool] = ["icomoon": false,
                                                  "Ionicons": false]

protocol FontProtocol {
    func errorAnnounce() -> String
    func familyName() -> String
    func fileName() -> String
    func fontName() -> String
}


/**
 FontType Enum
 
 ````
 case dripicon
 case emoji()
 case fontAwesomeRegular()
 case fontAwesomeBrands()
 case fontAwesomeSolid()
 case googleMaterialDesign()
 case icofont()
 case ionicons()
 case linearIcons()
 case mapicons()
 case openIconic()
 case state()
 case weather()
 ````
 */
public enum FontType: FontProtocol {
    /// It selects dripicon icon for the particular object from the library
    case customIcon(CustomIconType)
    case ionicons(IonicIconType)

    /**
     This function returns the font name using font type
     */
    func fontName() -> String {
        var fontName: String
        switch self {
        case .customIcon(_):
            fontName = "icomoon"
        case .ionicons(_):
            fontName = "Ionicons"
        }
        return fontName
    }
    
    /**
     This function returns the file name from Source folder using font type
     */
    func fileName() -> String {
        var fileName: String
        switch self {
        case .customIcon(_):
            fileName = "icomoon"
            break
        case .ionicons(_):
            fileName = "Ionicons"
            break
        }
        return fileName
    }
    
    /**
     This function returns the font family name using font type
     */
    func familyName() -> String {
        var familyName: String
        switch self {
        case .customIcon(_):
            familyName = "Icomoon"
            break
        case .ionicons(_):
            familyName = "Ionicons"
            break
        }
        return familyName
    }
    
    /**
     This function returns the error for a font type
     */
    func errorAnnounce() -> String {
        let message = " FONT - not associated with Info.plist when manual installation was performed";
        let fontName = self.fontName().uppercased()
        let errorAnnounce = fontName.appending(message)
        return errorAnnounce
    }
    
    /**
     This function returns the text for the icon
     */
    public var text: String? {
        var text: String
        
        switch self {
        case let .customIcon(icon):
            text = icon.rawValue
            break
        case let .ionicons(icon):
            text = icon.rawValue
            break
        }
        
        return text
    }
}



fileprivate func getAttributedString(prefixText: String, prefixTextColor: UIColor, prefixTextFont: UIFont, icons: [FontType], iconsSize: CGFloat, iconsColor: UIColor, postfixText: String, postfixTextColor: UIColor, postfixTextFont: UIFont) -> NSAttributedString {
    icons.forEach { FontLoader.loadFontIfNeeded(fontType: $0) }
    let iconFonts = icons.map { UIFont(name: $0.fontName(), size: iconsSize) }
    for (index, element) in iconFonts.enumerated() {
        assert(element != nil, icons[index].errorAnnounce())
    }
    
    let iconsString = icons.reduce("") { $0 + ($1.text ?? "") }
    let resultAttrString = NSMutableAttributedString(string: "\(prefixText)\(iconsString)\(postfixText)")
    
    //add prefix text attribute
    resultAttrString.addAttributes([
        NSAttributedString.Key.font: prefixTextFont,
        NSAttributedString.Key.foregroundColor: prefixTextColor,
        ], range: NSMakeRange(0, prefixText.count))
    
    //add icons attribute
    resultAttrString.addAttribute(NSAttributedString.Key.foregroundColor, value: iconsColor, range: NSMakeRange(prefixText.count, iconsString.count))
    for (index, _) in icons.enumerated() {
        resultAttrString.addAttribute(NSAttributedString.Key.font, value: iconFonts[index]!, range: NSMakeRange(prefixText.count + index, 1))
    }
    
    //add postfix text attribute
    if postfixText.count > 0 {
        resultAttrString.addAttributes([
            NSAttributedString.Key.font: postfixTextFont,
            NSAttributedString.Key.foregroundColor: postfixTextColor
            ], range: NSMakeRange(prefixText.count + iconsString.count, postfixText.count))
    }
    
    return resultAttrString
}

public enum CustomIconType: String {
//    case back = "\u{e900}"
    case close = "\u{e903}"
    case share = "\u{ea82}"
    case delete = "\u{e907}"
    case pencil = "\u{e909}"
    case message = "\u{e90a}"
    case key = "\u{e90e}"
    case heartOutline = "\u{e90f}"
    case heart = "\u{e910}"
    case checkmark = "\u{e92f}"
    case addOutline = "\u{e901}"
    case radioChecked = "\u{ea54}"
    case radioUnChecked = "\u{ea56}"
    case eye = "\u{f06e}"
    case pdfIcon = "\u{e902}"
    case crown = "\u{e904}"
    case noAds = "\u{e905}"
    case attension = "\u{e900}"
    case threedot = "\u{e938}"
}

public enum IonicIconType: String{
    case alert = "\u{f101}"
    case alertCircled = "\u{f100}"
    case androidAdd = "\u{f2c7}"
    case androidAddCircle = "\u{f359}"
    case androidAlarmClock = "\u{f35a}"
    case androidAlert = "\u{f35b}"
    case androidApps = "\u{f35c}"
    case androidArchive = "\u{f2c9}"
    case androidArrowBack = "\u{f2ca}"
    case androidArrowDown = "\u{f35d}"
    case androidArrowDropdown = "\u{f35f}"
    case androidArrowDropdownCircle = "\u{f35e}"
    case androidArrowDroplet = "\u{f361}"
    case androidArrowDropletCircle = "\u{f360}"
    case androidArrowDropright = "\u{f363}"
    case androidArrowDroprightCircle = "\u{f362}"
    case androidDropup = "\u{f365}"
    case androidDropupCircle = "\u{f364}"
    case androidArrowForward = "\u{f30f}"
    case androidArrowUp = "\u{f366}"
    case androidAttach = "\u{f367}"
    case androidBar = "\u{f368}"
    case androidBicycle = "\u{f369}"
    case androidBoat = "\u{f36a}"
    case androidBookmark = "\u{f36b}"
    case androidBulb = "\u{f36c}"
    case androidBus = "\u{f36d}"
    case androidCalendar = "\u{f2d1}"
    case androidCall = "\u{f2d2}"
    case androidCamera = "\u{f2d3}"
    case androidCancel = "\u{f36e}"
    case androidCar = "\u{f36f}"
    case androidCart = "\u{f370}"
    case androidChat = "\u{f2d4}"
    case androidCheckbox = "\u{f374}"
    case androidCheckboxBlank = "\u{f371}"
    case androidCheckboxOutline = "\u{f373}"
    case androidCheckboxOutlineBlank = "\u{f372}"
    case androidCheckmarkCircle = "\u{f375}"
    case androidClipboard = "\u{f376}"
    case androidClose = "\u{f2d7}"
    case androidCloud = "\u{f37a}"
    case androidCloudCircle = "\u{f377}"
    case androidCloudDone = "\u{f378}"
    case androidCloudOutline = "\u{f379}"
    case androidColorPalette = "\u{f37b}"
    case androidCompass = "\u{f37c}"
    case androidContact = "\u{f2d8}"
    case androidContacts = "\u{f2d9}"
    case androidContract = "\u{f37d}"
    case androidCreate = "\u{f37e}"
    case androidDelete = "\u{f37f}"
    case androidDesktop = "\u{f380}"
    case androidDocument = "\u{f381}"
    case androidDone = "\u{f383}"
    case androidDoneAll = "\u{f382}"
    case androidDownload = "\u{f2dd}"
    case androidDrafts = "\u{f384}"
    case androidExit = "\u{f385}"
    case androidExpand = "\u{f386}"
    case androidFavorite = "\u{f388}"
    case androidFavoriteOutline = "\u{f387}"
    case androidFilm = "\u{f389}"
    case androidFolder = "\u{f2e0}"
    case androidFolderOpen = "\u{f38a}"
    case androidFunnel = "\u{f38b}"
    case androidGlobe = "\u{f38c}"
    case androidHand = "\u{f2e3}"
    case androidHangout = "\u{f38d}"
    case androidHappy = "\u{f38e}"
    case androidHome = "\u{f38f}"
    case androidImage = "\u{f2e4}"
    case androidLaptop = "\u{f390}"
    case androidList = "\u{f391}"
    case androidLocate = "\u{f2e9}"
    case androidLock = "\u{f392}"
    case androidMail = "\u{f2eb}"
    case androidMap = "\u{f393}"
    case androidMenu = "\u{f394}"
    case androidMicrophone = "\u{f2ec}"
    case androidMicrophoneOff = "\u{f395}"
    case androidMoreHorizontal = "\u{f396}"
    case androidMoreVertical = "\u{f397}"
    case androidNavigate = "\u{f398}"
    case androidNotifications = "\u{f39b}"
    case androidNotificationsNone = "\u{f399}"
    case androidNotificationsOff = "\u{f39a}"
    case androidOpen = "\u{f39c}"
    case androidOptions = "\u{f39d}"
    case androidPeople = "\u{f39e}"
    case androidPerson = "\u{f3a0}"
    case androidPersonAdd = "\u{f39f}"
    case androidPhoneLandscape = "\u{f3a1}"
    case androidPhonePortrait = "\u{f3a2}"
    case androidPin = "\u{f3a3}"
    case androidPlane = "\u{f3a4}"
    case androidPlaystore = "\u{f2f0}"
    case androidPrint = "\u{f3a5}"
    case androidRadioButtonOff = "\u{f3a6}"
    case androidRadioButtonOn = "\u{f3a7}"
    case androidRefresh = "\u{f3a8}"
    case androidRemove = "\u{f2f4}"
    case androidRemoveCircle = "\u{f3a9}"
    case androidRestaurant = "\u{f3aa}"
    case androidSad = "\u{f3ab}"
    case androidSearch = "\u{f2f5}"
    case androidSend = "\u{f2f6}"
    case androidSettings = "\u{f2f7}"
    case androidShare = "\u{f2f8}"
    case androidShareAlt = "\u{f3ac}"
    case androidStar = "\u{f2fc}"
    case androidStarHalf = "\u{f3ad}"
    case androidStarOutline = "\u{f3ae}"
    case androidStopwatch = "\u{f2fd}"
    case androidSubway = "\u{f3af}"
    case androidSunny = "\u{f3b0}"
    case androidSync = "\u{f3b1}"
    case androidTextsms = "\u{f3b2}"
    case androidTime = "\u{f3b3}"
    case androidTrain = "\u{f3b4}"
    case androidUnlock = "\u{f3b5}"
    case androidUpload = "\u{f3b6}"
    case androidVolumeDown = "\u{f3b7}"
    case androidVolumeMute = "\u{f3b8}"
    case androidVolumeOff = "\u{f3b9}"
    case androidVolumeUp = "\u{f3ba}"
    case androidWalk = "\u{f3bb}"
    case androidWarning = "\u{f3bc}"
    case androidWatch = "\u{f3bd}"
    case androidWifi = "\u{f305}"
    case aperture = "\u{f313}"
    case archive = "\u{f102}"
    case arrowDownA = "\u{f103}"
    case arrowDownB = "\u{f104}"
    case arrowDownC = "\u{f105}"
    case arrowExpand = "\u{f25e}"
    case arrowGraphDownLeft = "\u{f25f}"
    case arrowGraphDownRight = "\u{f260}"
    case arrowGraphUpLeft = "\u{f261}"
    case arrowGraphUpRight = "\u{f262}"
    case arrowLeftA = "\u{f106}"
    case arrowLeftB = "\u{f107}"
    case arrowLeftC = "\u{f108}"
    case arrowMove = "\u{f263}"
    case arrowResize = "\u{f264}"
    case arrowReturnLeft = "\u{f265}"
    case arrowReturnRight = "\u{f266}"
    case arrowRightA = "\u{f109}"
    case arrowRightB = "\u{f10a}"
    case arrowRightC = "\u{f10b}"
    case arrowShrink = "\u{f267}"
    case arrowSwap = "\u{f268}"
    case arrowUpA = "\u{f10c}"
    case arrowUpB = "\u{f10d}"
    case arrowUpC = "\u{f10e}"
    case asterisk = "\u{f314}"
    case at = "\u{f10f}"
    case backspace = "\u{f3bf}"
    case backspaceOutline = "\u{f3be}"
    case bag = "\u{f110}"
    case batteryCharging = "\u{f111}"
    case batteryEmpty = "\u{f112}"
    case batteryFull = "\u{f113}"
    case batteryHalf = "\u{f114}"
    case batteryLow = "\u{f115}"
    case beaker = "\u{f269}"
    case beer = "\u{f26a}"
    case bluetooth = "\u{f116}"
    case bonfire = "\u{f315}"
    case bookmark = "\u{f26b}"
    case bowtie = "\u{f3c0}"
    case briefcase = "\u{f26c}"
    case bug = "\u{f2be}"
    case calculator = "\u{f26d}"
    case calendar = "\u{f117}"
    case camera = "\u{f118}"
    case card = "\u{f119}"
    case cash = "\u{f316}"
    case chatbox = "\u{f11b}"
    case chatboxWorking = "\u{f11a}"
    case chatboxes = "\u{f11c}"
    case chatbubble = "\u{f11e}"
    case chatbubbleWorking = "\u{f11d}"
    case chatbubbles = "\u{f11f}"
    case checkmark = "\u{f122}"
    case checkmarkCircled = "\u{f120}"
    case checkmarkRound = "\u{f121}"
    case chevronDown = "\u{f123}"
    case chevronLeft = "\u{f124}"
    case chevronRight = "\u{f125}"
    case chevronUp = "\u{f126}"
    case clipboard = "\u{f127}"
    case clock = "\u{f26e}"
    case close = "\u{f12a}"
    case closeCircled = "\u{f128}"
    case closeRound = "\u{f129}"
    case closedCaptioning = "\u{f317}"
    case cloud = "\u{f12b}"
    case code = "\u{f271}"
    case codeDownload = "\u{f26f}"
    case codeWorking = "\u{f270}"
    case coffee = "\u{f272}"
    case compass = "\u{f273}"
    case compose = "\u{f12c}"
    case connectionBars = "\u{f274}"
    case contrast = "\u{f275}"
    case crop = "\u{f3c1}"
    case cube = "\u{f318}"
    case disc = "\u{f12d}"
    case document = "\u{f12f}"
    case documentText = "\u{f12e}"
    case drag = "\u{f130}"
    case earth = "\u{f276}"
    case easel = "\u{f3c2}"
    case edit = "\u{f2bf}"
    case egg = "\u{f277}"
    case eject = "\u{f131}"
    case email = "\u{f132}"
    case emailUnread = "\u{f3c3}"
    case erlenmeyerFlask = "\u{f3c5}"
    case erlenmeyerFlaskBubbles = "\u{f3c4}"
    case eye = "\u{f133}"
    case eyeDisabled = "\u{f306}"
    case female = "\u{f278}"
    case filing = "\u{f134}"
    case filmMaker = "\u{f135}"
    case fireball = "\u{f319}"
    case flag = "\u{f279}"
    case flame = "\u{f31a}"
    case flash = "\u{f137}"
    case flashOff = "\u{f136}"
    case folder = "\u{f139}"
    case fork = "\u{f27a}"
    case forkRepo = "\u{f2c0}"
    case forward = "\u{f13a}"
    case funnel = "\u{f31b}"
    case gearA = "\u{f13d}"
    case gearB = "\u{f13e}"
    case grid = "\u{f13f}"
    case hammer = "\u{f27b}"
    case happy = "\u{f31c}"
    case happyOutline = "\u{f3c6}"
    case headphone = "\u{f140}"
    case heart = "\u{f141}"
    case heartBroken = "\u{f31d}"
    case help = "\u{f143}"
    case helpBuoy = "\u{f27c}"
    case helpCircled = "\u{f142}"
    case home = "\u{f144}"
    case icecream = "\u{f27d}"
    case image = "\u{f147}"
    case images = "\u{f148}"
    case information = "\u{f14a}"
    case informationCircled = "\u{f149}"
    case ionic = "\u{f14b}"
    case iosAlarm = "\u{f3c8}"
    case iosAlarmOutline = "\u{f3c7}"
    case iosAlbums = "\u{f3ca}"
    case iosAlbumsOutline = "\u{f3c9}"
    case iosAmericanfootball = "\u{f3cc}"
    case iosAmericanfootballOutline = "\u{f3cb}"
    case iosAnalytics = "\u{f3ce}"
    case iosAnalyticsOutline = "\u{f3cd}"
    case iosArrowBack = "\u{f3cf}"
    case iosArrowDown = "\u{f3d0}"
    case iosArrowForward = "\u{f3d1}"
    case iosArrowLeft = "\u{f3d2}"
    case iosArrowRight = "\u{f3d3}"
    case iosArrowThinDown = "\u{f3d4}"
    case iosArrowThinLeft = "\u{f3d5}"
    case iosArrowThinRight = "\u{f3d6}"
    case iosArrowThinUp = "\u{f3d7}"
    case iosArrowUp = "\u{f3d8}"
    case iosAt = "\u{f3da}"
    case iosAtOutline = "\u{f3d9}"
    case iosBarcode = "\u{f3dc}"
    case iosBarcodeOutline = "\u{f3db}"
    case iosBaseball = "\u{f3de}"
    case iosBaseballOutline = "\u{f3dd}"
    case iosBasketball = "\u{f3e0}"
    case iosBasketBallOutline = "\u{f3df}"
    case iosBell = "\u{f3e2}"
    case iosBellOutline = "\u{f3e1}"
    case iosBody = "\u{f3e4}"
    case iosBodyOutline = "\u{f3e3}"
    case iosBolt = "\u{f3e6}"
    case iosBoltOutline = "\u{f3e5}"
    case iosBook = "\u{f3e8}"
    case iosBookOutline = "\u{f3e7}"
    case iosBookmarks = "\u{f3ea}"
    case iosBookmarksOutline = "\u{f3e9}"
    case iosBox = "\u{f3ec}"
    case iosBoxOutline = "\u{f3eb}"
    case iosBriefcase = "\u{f3ee}"
    case iosBriefcaseOutline = "\u{f3ed}"
    case iosBrowsers = "\u{f3f0}"
    case iosBrowsersOutline = "\u{f3ef}"
    case iosCalculator = "\u{f3f2}"
    case iosCalculatorOutline = "\u{f3f1}"
    case iosCalendar = "\u{f3f4}"
    case iosCalendarOutline = "\u{f3f3}"
    case iosCamera = "\u{f3f6}"
    case iosCameraOutline = "\u{f3f5}"
    case iosCart = "\u{f3f8}"
    case iosCartOutline = "\u{f3f7}"
    case iosChatboxes = "\u{f3fa}"
    case iosChatboxesOutline = "\u{f3f9}"
    case iosChatbubble = "\u{f3fc}"
    case iosChatbubbleOutline = "\u{f3fb}"
    case iosCheckmark = "\u{f3ff}"
    case iosCheckmarkEmpty = "\u{f3fd}"
    case iosCheckmarkOutline = "\u{f3fe}"
    case iosCircleFilled = "\u{f400}"
    case iosCircleOutline = "\u{f401}"
    case iosClock = "\u{f403}"
    case iosClockOutline = "\u{f402}"
    case iosClose = "\u{f406}"
    case iosCloseEmpty = "\u{f404}"
    case iosCloseOutline = "\u{f405}"
    case iosCloud = "\u{f40c}"
    case iosCloudDownload = "\u{f408}"
    case iosCloudDownloadOutline = "\u{f407}"
    case iosCloudOutline = "\u{f409}"
    case iosCloudUpload = "\u{f40b}"
    case iosCloudUploadOutline = "\u{f40a}"
    case iosCloudy = "\u{f410}"
    case iosCloudyNight = "\u{f40e}"
    case iosCloudyNightOutline = "\u{f40d}"
    case iosCloudyOutline = "\u{f40f}"
    case iosCog = "\u{f412}"
    case iosCogOutline = "\u{f411}"
    case iosColorFilter = "\u{f414}"
    case iosColorFilterOutline = "\u{f413}"
    case iosColorWand = "\u{f416}"
    case iosColorWandOutline = "\u{f415}"
    case iosCompose = "\u{f418}"
    case iosComposeOutline = "\u{f417}"
    case iosContact = "\u{f41a}"
    case iosContactOutline = "\u{f419}"
    case iosCopy = "\u{f41c}"
    case iosCopyOutline = "\u{f41b}"
    case iosCrop = "\u{f41e}"
    case iosCropStrong = "\u{f41d}"
    case iosDownload = "\u{f420}"
    case iosDownloadOutline = "\u{f41f}"
    case iosDrag = "\u{f421}"
    case iosEmail = "\u{f423}"
    case iosEmailOutline = "\u{f422}"
    case iosEye = "\u{f425}"
    case iosEyeOutline = "\u{f424}"
    case iosFastforward = "\u{f427}"
    case iosFastforwardOutline = "\u{f426}"
    case iosFiling = "\u{f429}"
    case iosFilingOutline = "\u{f428}"
    case iosFilm = "\u{f42b}"
    case iosFilmOutline = "\u{f42a}"
    case iosFlag = "\u{f42d}"
    case iosFlagOutline = "\u{f42c}"
    case iosFlame = "\u{f42f}"
    case iosFlameOutline = "\u{f42e}"
    case iosFlask = "\u{f431}"
    case iosFlaskOutline = "\u{f430}"
    case iosFlower = "\u{f433}"
    case iosFlowerOutline = "\u{f432}"
    case iosFolder = "\u{f435}"
    case iosFolderOutline = "\u{f434}"
    case iosFootball = "\u{f437}"
    case iosFootballOutline = "\u{f436}"
    case iosGameControllerA = "\u{f439}"
    case iosGameControllerAOutline = "\u{f438}"
    case iosGameControllerB = "\u{f43b}"
    case iosGameControllerBOutline = "\u{f43a}"
    case iosGear = "\u{f43d}"
    case iosGearOutline = "\u{f43c}"
    case iosGlasses = "\u{f43f}"
    case iosGlassesOutline = "\u{f43e}"
    case iosGridView = "\u{f441}"
    case iosGridViewOutline = "\u{f440}"
    case iosHeart = "\u{f443}"
    case iosHeartOutline = "\u{f442}"
    case iosHelp = "\u{f446}"
    case iosHelpEmpty = "\u{f444}"
    case iosHelpOutline = "\u{f445}"
    case iosHome = "\u{f448}"
    case iosHomeOutline = "\u{f447}"
    case iosInfinite = "\u{f44a}"
    case iosInfiniteOutline = "\u{f449}"
    case iosInformation = "\u{f44d}"
    case iosInformationEmpty = "\u{f44b}"
    case iosInformationOutline = "\u{f44c}"
    case iosIonicOutline = "\u{f44e}"
    case iosKeypad = "\u{f450}"
    case iosKeypadOutline = "\u{f44f}"
    case iosLightbulb = "\u{f452}"
    case iosLightbulbOutline = "\u{f451}"
    case iosList = "\u{f454}"
    case iosListOutline = "\u{f453}"
    case iosLocation = "\u{f456}"
    case iosLocationOutline = "\u{f455}"
    case iosLocked = "\u{f458}"
    case iosLockedOutline = "\u{f457}"
    case iosLoop = "\u{f45a}"
    case iosLoopStrong = "\u{f459}"
    case iosMedical = "\u{f45c}"
    case iosMedicalOutline = "\u{f45b}"
    case iosMedkit = "\u{f45e}"
    case iosMedkitOutline = "\u{f45d}"
    case iosMic = "\u{f461}"
    case iosMicOff = "\u{f45f}"
    case iosMicOutline = "\u{f460}"
    case iosMinus = "\u{f464}"
    case iosMinusEmpty = "\u{f462}"
    case iosMinusOutline = "\u{f463}"
    case iosMonitor = "\u{f466}"
    case iosMonitorOutline = "\u{f465}"
    case iosMoon = "\u{f468}"
    case iosMoonOutline = "\u{f467}"
    case iosMore = "\u{f46a}"
    case iosMoreOutline = "\u{f469}"
    case iosMusicalNote = "\u{f46b}"
    case iosMusicalNotes = "\u{f46c}"
    case iosNavigate = "\u{f46e}"
    case iosNavigateOutline = "\u{f46d}"
    case iosNutrition = "\u{f470}"
    case iosNutritionOutline = "\u{f46f}"
    case iosPaper = "\u{f472}"
    case iosPaperOutline = "\u{f471}"
    case iosPaperplane = "\u{f474}"
    case iosPaperplaneOutline = "\u{f473}"
    case iosPartlySunny = "\u{f476}"
    case iosPartlySunnyOutline = "\u{f475}"
    case iosPause = "\u{f478}"
    case iosPauseOutline = "\u{f477}"
    case iosPaw = "\u{f47a}"
    case iosPawOutline = "\u{f479}"
    case iosPeople = "\u{f47c}"
    case iosPeopleOutline = "\u{f47b}"
    case iosPerson = "\u{f47e}"
    case iosPersonOutline = "\u{f47d}"
    case iosPersonadd = "\u{f480}"
    case iosPersonaddOutline = "\u{f47f}"
    case iosPhotos = "\u{f482}"
    case iosPhotosOutline = "\u{f481}"
    case iosPie = "\u{f484}"
    case iosPieOutline = "\u{f483}"
    case iosPint = "\u{f486}"
    case iosPintOutline = "\u{f485}"
    case iosPlay = "\u{f488}"
    case iosPlayOutline = "\u{f487}"
    case iosPlus = "\u{f48b}"
    case iosPlusEmpty = "\u{f489}"
    case iosPlusOutline = "\u{f48a}"
    case iosPricetag = "\u{f48d}"
    case iosPricetagOutline = "\u{f48c}"
    case iosPricetags = "\u{f48f}"
    case iosPricetagsOutline = "\u{f48e}"
    case iosPrinter = "\u{f491}"
    case iosPrinterOutline = "\u{f490}"
    case iosPulse = "\u{f493}"
    case iosPulseStrong = "\u{f492}"
    case iosRainy = "\u{f495}"
    case iosRainyOutline = "\u{f494}"
    case iosRecording = "\u{f497}"
    case iosRecordingOutline = "\u{f496}"
    case iosRedo = "\u{f499}"
    case iosRedoOutline = "\u{f498}"
    case iosRefresh = "\u{f49c}"
    case iosRefreshEmpty = "\u{f49a}"
    case iosRefreshOutline = "\u{f49b}"
    case iosReload = "\u{f49d}"
    case iosReverseCamera = "\u{f49f}"
    case iosReverseCameraOutline = "\u{f49e}"
    case iosRewind = "\u{f4a1}"
    case iosRewindOutline = "\u{f4a0}"
    case iosRose = "\u{f4a3}"
    case iosRoseOutline = "\u{f4a2}"
    case iosSearch = "\u{f4a5}"
    case iosSearchStrong = "\u{f4a4}"
    case iosSettings = "\u{f4a7}"
    case iosSettingsStrong = "\u{f4a6}"
    case iosShuffle = "\u{f4a9}"
    case iosShuffleStrong = "\u{f4a8}"
    case iosSkipbackward = "\u{f4ab}"
    case iosSkipbackwardOutline = "\u{f4aa}"
    case iosSkipforward = "\u{f4ad}"
    case iosSkipforwardOutline = "\u{f4ac}"
    case iosSnowy = "\u{f4ae}"
    case iosSpeedometer = "\u{f4b0}"
    case iosSpeedometerOutline = "\u{f4af}"
    case iosStar = "\u{f4b3}"
    case iosStarHalf = "\u{f4b1}"
    case iosStarOutline = "\u{f4b2}"
    case iosStopwatch = "\u{f4b5}"
    case iosStopwatchOutline = "\u{f4b4}"
    case iosSunny = "\u{f4b7}"
    case iosSunnyOutline = "\u{f4b6}"
    case iosTelephone = "\u{f4b9}"
    case iosTelephoneOutline = "\u{f4b8}"
    case iosTennisball = "\u{f4bb}"
    case iosTennisballOutline = "\u{f4ba}"
    case iosThunderstorm = "\u{f4bd}"
    case iosThunderstormOutline = "\u{f4bc}"
    case iosTime = "\u{f4bf}"
    case iosTimeOutline = "\u{f4be}"
    case iosTimer = "\u{f4c1}"
    case iosTimerOutline = "\u{f4c0}"
    case iosToggle = "\u{f4c3}"
    case iosToggleOutline = "\u{f4c2}"
    case iosTrash = "\u{f4c5}"
    case iosTrashOutline = "\u{f4c4}"
    case iosUndo = "\u{f4c7}"
    case iosUndoOutline = "\u{f4c6}"
    case iosUnlocked = "\u{f4c9}"
    case iosUnlockedOutline = "\u{f4c8}"
    case iosUpload = "\u{f4cb}"
    case iosUploadOutline = "\u{f4ca}"
    case iosVideocam = "\u{f4cd}"
    case iosVideocamOutline = "\u{f4cc}"
    case iosVolumeHigh = "\u{f4ce}"
    case iosVolumeLow = "\u{f4cf}"
    case iosWineglass = "\u{f4d1}"
    case iosWineglassOutline = "\u{f4d0}"
    case iosWorld = "\u{f4d3}"
    case iosWorldOutline = "\u{f4d2}"
    case ipad = "\u{f1f9}"
    case iphone = "\u{f1fa}"
    case ipod = "\u{f1fb}"
    case jet = "\u{f295}"
    case key = "\u{f296}"
    case knife = "\u{f297}"
    case laptop = "\u{f1fc}"
    case leaf = "\u{f1fd}"
    case levels = "\u{f298}"
    case lightbulb = "\u{f299}"
    case link = "\u{f1fe}"
    case loadA = "\u{f29a}"
    case loadB = "\u{f29b}"
    case loadC = "\u{f29c}"
    case loadD = "\u{f29d}"
    case location = "\u{f1ff}"
    case lockCombination = "\u{f4d4}"
    case locked = "\u{f200}"
    case logIn = "\u{f29e}"
    case logOut = "\u{f29f}"
    case loop = "\u{f201}"
    case magnet = "\u{f2a0}"
    case male = "\u{f2a1}"
    case man = "\u{f202}"
    case map = "\u{f203}"
    case medkit = "\u{f2a2}"
    case merge = "\u{f33f}"
    case micA = "\u{f204}"
    case micB = "\u{f205}"
    case micC = "\u{f206}"
    case minus = "\u{f209}"
    case minusCircled = "\u{f207}"
    case minusRound = "\u{f208}"
    case modelS = "\u{f2c1}"
    case monitor = "\u{f20a}"
    case more = "\u{f20b}"
    case mouse = "\u{f340}"
    case musicNote = "\u{f20c}"
    case navicon = "\u{f20e}"
    case naviconRound = "\u{f20d}"
    case navigate = "\u{f2a3}"
    case network = "\u{f341}"
    case noSmoking = "\u{f2c2}"
    case nuclear = "\u{f2a4}"
    case outlet = "\u{f342}"
    case paintbrush = "\u{f4d5}"
    case paintbucket = "\u{f4d6}"
    case paperAirplane = "\u{f2c3}"
    case paperclip = "\u{f20f}"
    case pause = "\u{f210}"
    case person = "\u{f213}"
    case personAdd = "\u{f211}"
    case personStalker = "\u{f212}"
    case pieGraph = "\u{f2a5}"
    case pin = "\u{f2a6}"
    case pinpoint = "\u{f2a7}"
    case pizza = "\u{f2a8}"
    case plane = "\u{f214}"
    case planet = "\u{f343}"
    case play = "\u{f215}"
    case playstation = "\u{f30a}"
    case plus = "\u{f218}"
    case plusCircled = "\u{f216}"
    case plusRound = "\u{f217}"
    case podium = "\u{f344}"
    case pound = "\u{f219}"
    case power = "\u{f2a9}"
    case pricetag = "\u{f2aa}"
    case pricetags = "\u{f2ab}"
    case printer = "\u{f21a}"
    case pullRequest = "\u{f345}"
    case qrScanner = "\u{f346}"
    case quote = "\u{f347}"
    case radioWaves = "\u{f2ac}"
    case record = "\u{f21b}"
    case refresh = "\u{f21c}"
    case reply = "\u{f21e}"
    case replyAll = "\u{f21d}"
    case ribbonA = "\u{f348}"
    case ribbonB = "\u{f349}"
    case sad = "\u{f34a}"
    case sadOutline = "\u{f4d7}"
    case scissors = "\u{f34b}"
    case search = "\u{f21f}"
    case settings = "\u{f2ad}"
    case share = "\u{f220}"
    case shuffle = "\u{f221}"
    case skipBackward = "\u{f222}"
    case skipForward = "\u{f223}"
    case socialAndroid = "\u{f225}"
    case socialAndroidOutline = "\u{f224}"
    case socialAngular = "\u{f4d9}"
    case socialAngularOutline = "\u{f4d8}"
    case socialApple = "\u{f227}"
    case socialAppleOutline = "\u{f226}"
    case socialBitcoin = "\u{f2af}"
    case socialBitcoinOutline = "\u{f2ae}"
    case socialBuffer = "\u{f229}"
    case socialBufferOutline = "\u{f228}"
    case socialChrome = "\u{f4db}"
    case socialChromeOutline = "\u{f4da}"
    case socialCodepan = "\u{f4dd}"
    case socialCodepanOutline = "\u{f4dc}"
    case socialCss3 = "\u{f4df}"
    case socialCss3Outline = "\u{f4de}"
    case socialDesignernews = "\u{f22b}"
    case socialDesignernewsOutline = "\u{f22a}"
    case socialDribble = "\u{f22d}"
    case socialDribbleOutline = "\u{f22c}"
    case socialDropbox = "\u{f22f}"
    case socialDropboxOutline = "\u{f22e}"
    case socialEuro = "\u{f4e1}"
    case socialEuroOutline = "\u{f4e0}"
    case socialFacebook = "\u{f231}"
    case socialFacebookOutline = "\u{f230}"
    case socialFoursquare = "\u{f34d}"
    case socialFoursquareOutline = "\u{f34c}"
    case socialFreebsdDevil = "\u{f2c4}"
    case socialGithub = "\u{f233}"
    case socialGithubOutline = "\u{f232}"
    case socialGoogle = "\u{f34f}"
    case socialGoogleOutline = "\u{f34e}"
    case socialGoogleplus = "\u{f235}"
    case socialGoogleplusOutline = "\u{f234}"
    case socialHackernews = "\u{f237}"
    case socialHackernewsOutline = "\u{f236}"
    case socialHtml5 = "\u{f4e3}"
    case socialHtml5Outline = "\u{f4e2}"
    case socialInstagram = "\u{f351}"
    case socialInstagramOutline = "\u{f350}"
    case socialJavascript = "\u{f4e5}"
    case socialJavascriptOutline = "\u{f4e4}"
    case socialLinkedin = "\u{f239}"
    case socialLinkedinOutline = "\u{f238}"
    case socialMarkdown = "\u{f4e6}"
    case socialNodejs = "\u{f4e7}"
    case socialOctacat = "\u{f4e8}"
    case socialPinterest = "\u{f2b1}"
    case socialPinterestOutline = "\u{f2b0}"
    case socialPython = "\u{f4e9}"
    case socialReddit = "\u{f23b}"
    case socialRedditOutline = "\u{f23a}"
    case socialRss = "\u{f23d}"
    case socialRssOutline = "\u{f23c}"
    case socialSass = "\u{f4ea}"
    case socialSkype = "\u{f23f}"
    case socialSkypeOutline = "\u{f23e}"
    case socialSnapchat = "\u{f4ec}"
    case socialSnapchatOutline = "\u{f4eb}"
    case socialTumblr = "\u{f241}"
    case socialTumblrOutline = "\u{f240}"
    case socialTux = "\u{f2c5}"
    case socialTwitch = "\u{f4ee}"
    case socialTwitchOutline = "\u{f4ed}"
    case socialTwitter = "\u{f243}"
    case socialTwitterOutline = "\u{f242}"
    case socialUsd = "\u{f353}"
    case socialUsdOutline = "\u{f352}"
    case socialVimeo = "\u{f245}"
    case socialVimeoOutline = "\u{f244}"
    case socialWhatsapp = "\u{f4f0}"
    case socialWhatsappOutline = "\u{f4ff}"
    case socialWindows = "\u{f247}"
    case socialWindowsOutline = "\u{f246}"
    case socialWordpress = "\u{f249}"
    case socialWordpressOutline = "\u{f248}"
    case socialYahoo = "\u{f24b}"
    case socialYahooOutline = "\u{f24a}"
    case socialYen = "\u{f4f2}"
    case socialYenOutline = "\u{f4f1}"
    case socialYoutube = "\u{f24d}"
    case socialYoutubeOutline = "\u{f24c}"
    case soupCan = "\u{f4f4}"
    case soupCanOutline = "\u{f4f3}"
    case speakerphone = "\u{f2b2}"
    case speedometer = "\u{f2b3}"
    case spoon = "\u{f2b4}"
    case star = "\u{f24e}"
    case statsBars = "\u{f2b5}"
    case steam = "\u{f30b}"
    case stop = "\u{f24f}"
    case thermometer = "\u{f2b6}"
    case thumbsdown = "\u{f250}"
    case thumbsup = "\u{f251}"
    case toggle = "\u{f355}"
    case toggleFilled = "\u{f354}"
    case transgender = "\u{f4f5}"
    case trashA = "\u{f252}"
    case trashB = "\u{f253}"
    case trophy = "\u{f356}"
    case tshirt = "\u{f4f7}"
    case tshirtOutline = "\u{f4f6}"
    case umbrella = "\u{f2b7}"
    case university = "\u{f357}"
    case unlocked = "\u{f254}"
    case upload = "\u{f255}"
    case usb = "\u{f2b8}"
    case videocamera = "\u{f256}"
    case volumeHigh = "\u{f257}"
    case volumeLow = "\u{f258}"
    case volumeMedium = "\u{f259}"
    case volumeMute = "\u{f25a}"
    case wand = "\u{f358}"
    case waterdrop = "\u{f25b}"
    case wifi = "\u{f25c}"
    case wineglass = "\u{f2b9}"
    case woman = "\u{f25d}"
    case wrench = "\u{f2ba}"
    case xbox = "\u{f30c}"

}

