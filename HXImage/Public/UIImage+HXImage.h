//
//  UIImage+HXImage.h
//  HXImage
//
//  Created by 冷秋 on 2018/7/3.
//  Copyright © 2018年 unique. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HXImage)

+ (instancetype)hx_imageNamed:(NSString *)name;

+ (instancetype)hx_imageNamed:(NSString *)name inDirectory:(NSString *)directory;

+ (instancetype)hx_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

+ (instancetype)hx_imageWithContentsOfFile:(NSString *)path;

@end
