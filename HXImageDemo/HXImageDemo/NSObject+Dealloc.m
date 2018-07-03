//
//  NSObject+Dealloc.m
//  HXImageDemo
//
//  Created by 冷秋 on 2018/7/3.
//  Copyright © 2018年 unique. All rights reserved.
//

#import "NSObject+Dealloc.h"
#import <objc/runtime.h>

@interface HXDeallocTask : NSObject

@property (nonatomic, copy) void (^task)(void);

+ (instancetype)task:(void(^)(void))task;

@end

@implementation NSObject (Dealloc)

- (void)onDealloc:(void (^)(void))handler {
    objc_setAssociatedObject(self, "dealloc", [HXDeallocTask task:handler], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation HXDeallocTask

+ (instancetype)task:(void (^)(void))task {
    HXDeallocTask *_task = [self new];
    _task.task = task;
    return _task;
}

- (void)dealloc {
    !_task?:_task();
}

@end


