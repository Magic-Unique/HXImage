//
//  HXImageManager.h
//  HXImage
//
//  Created by 冷秋 on 2018/7/3.
//  Copyright © 2018年 unique. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXImageManager : NSObject

+ (instancetype)sharedManager;

- (UIImage *)imageNamed:(NSString *)name inDirectory:(NSString *)directory;

- (UIImage *)imageWithContentsOfFile:(NSString *)path;

@end
