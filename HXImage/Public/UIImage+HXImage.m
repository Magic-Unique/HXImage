//
//  UIImage+HXImage.m
//  HXImage
//
//  Created by 冷秋 on 2018/7/3.
//  Copyright © 2018年 unique. All rights reserved.
//

#import "UIImage+HXImage.h"
#import "HXImageManager.h"

@implementation UIImage (HXImage)

+ (instancetype)hx_imageNamed:(NSString *)name {
    return [self hx_imageNamed:name inBundle:NSBundle.mainBundle];
}

+ (instancetype)hx_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    return [self hx_imageNamed:name inDirectory:bundle.bundlePath];
}

+ (instancetype)hx_imageNamed:(NSString *)name inDirectory:(NSString *)directory {
    return [[HXImageManager sharedManager] imageNamed:name inDirectory:directory];
}

+ (instancetype)hx_imageWithContentsOfFile:(NSString *)path {
    return [[HXImageManager sharedManager] imageWithContentsOfFile:path];
}

@end
