//
//  KBImageManager.h
//  Kuber
//
//  Created by Kuber on 16/3/30.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface KBImageManager : NSObject

+ (instancetype)defaultManager;

- (UIImage *)getImageWithName:(NSString *)name;

@end
