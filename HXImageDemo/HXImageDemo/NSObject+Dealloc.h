//
//  NSObject+Dealloc.h
//  HXImageDemo
//
//  Created by 冷秋 on 2018/7/3.
//  Copyright © 2018年 unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Dealloc)

- (void)onDealloc:(void(^)(void))handler;

@end
