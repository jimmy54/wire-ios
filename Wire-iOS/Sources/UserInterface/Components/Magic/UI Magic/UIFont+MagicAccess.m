// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 



#import "UIFont+MagicAccess.h"
#import "WAZUIMagic.h"

#import <CoreText/CoreText.h>


@implementation UIFont (MagicAccess)

+ (UIFont *)fontWithMagicIdentifier:(NSString *)identifier
{
    static NSMutableDictionary *fontCache;

    WAZUIMagic *magic = [WAZUIMagic sharedMagic];
    NSDictionary *attributes = magic[identifier];
    NSString *fontName = attributes[@"font"];
    NSNumber *fontSize = attributes[@"size"];
    CGFloat fontSizeFloat = [fontSize floatValue];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fontCache = [NSMutableDictionary dictionary];
    });

    UIFont *cached = fontCache[identifier];
    if (cached) {return cached;}

    if ([fontName hasPrefix:@"System"]) {
        
        NSString *weightString = @"Regular";
        NSArray *nameComponents = [fontName componentsSeparatedByString:@"-"];
        if (nameComponents.count == 2) {
            weightString = nameComponents[1];
        }
        
        NSMutableArray *featureAttributes = [NSMutableArray array];
        
        if ([attributes[@"number_spacing"] isEqualToString:@"proportional"]) {
            [featureAttributes addObject:@{UIFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                           UIFontFeatureSelectorIdentifierKey: @(kProportionalNumbersSelector)}];
        } else if ([attributes[@"number_spacing"] isEqualToString:@"monospace"]) {
            [featureAttributes addObject:@{UIFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                           UIFontFeatureSelectorIdentifierKey: @(kMonospacedNumbersSelector)}];
        }
        
        UIFont *systemFont = [UIFont systemFontOfSize:fontSizeFloat];
        UIFontDescriptor *descriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{UIFontDescriptorFaceAttribute: weightString, 
                                                                                            UIFontDescriptorFamilyAttribute: systemFont.familyName,
                                                                                            UIFontDescriptorFeatureSettingsAttribute: featureAttributes}];
        UIFont *font = [UIFont fontWithDescriptor:descriptor size:fontSizeFloat];
        fontCache[identifier] = font;
        return font;
    }
    else {
        UIFont *font = [UIFont fontWithName:fontName size:fontSizeFloat];
        NSAssert(font != nil, @"Cannot load font");
        fontCache[identifier] = font;
        return font;
    }

    return nil;
}

+ (UIFont *)fontWithMagicIdentifierFontNameKey:(NSString *)fontNameKey fontSizeKey:(NSString *)fontSizeKey
{
    WAZUIMagic *magic = [WAZUIMagic sharedMagic];
    NSString *fontName = magic[fontNameKey];
    CGFloat fontSize = [WAZUIMagic cgFloatForIdentifier:fontSizeKey];
    if (fontName && fontSize > 0) {
        return [UIFont fontWithName:fontName size:fontSize];
    }
    return nil;
}

+ (UIFont *)fontWithMagicIdentifierPrefixPath:(NSString *)path
{
    if (0 == [path length]) {
        return nil;
    }
    return [[self class] fontWithMagicIdentifierFontNameKey:[NSString stringWithFormat:@"%@_font", path] fontSizeKey:[NSString stringWithFormat:@"%@_font_size", path]];
}

@end
