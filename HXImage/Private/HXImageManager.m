//
//  HXImageManager.m
//  HXImage
//
//  Created by 冷秋 on 2018/7/3.
//  Copyright © 2018年 unique. All rights reserved.
//

#import "HXImageManager.h"
#import "NSString+HXImage.h"

@interface HXImageManager ()

@property (nonatomic, strong, readonly) NSMapTable<NSString *, UIImage *> *caches;

@end

@implementation HXImageManager

+ (instancetype)sharedManager {
    static HXImageManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [self new];
    });
    return _manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _caches = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn
                                        valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

- (UIImage *)imageNamed:(NSString *)name inDirectory:(NSString *)directory {
    NSString *MD5 = [directory stringByAppendingPathComponent:name].hx_MD5;
    UIImage *image = [self.caches objectForKey:MD5];
    if (image == nil) {
        NSString *keyNamed = name;
        NSUInteger scale = 0;
        NSString *type = nil;
        if (keyNamed.hx_containsType) {
            type = keyNamed.hx_type;
            keyNamed = keyNamed.hx_removeType;
        }
        if (keyNamed.hx_containsScale) {
            scale = keyNamed.hx_scale;
            keyNamed = keyNamed.hx_removeScale;
        }
        image = [self __searchImageNamed:keyNamed scale:scale type:type inDirectory:directory];
        if (image) {
            [self.caches setObject:image forKey:MD5];
        }
    }
    return image;
}

- (UIImage *)imageWithContentsOfFile:(NSString *)path {
    NSString *MD5 = path.hx_MD5;
    UIImage *image = [self.caches objectForKey:MD5];
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:path];
        if (image) {
            [self.caches setObject:image forKey:MD5];
        }
    }
    return image;
}

- (UIImage *)__searchImageNamed:(NSString *)name scale:(NSUInteger)scale type:(NSString *)type inDirectory:(NSString *)directory {
    NSArray *scales = [self __scaleSuffixWithScale:scale];
    NSArray *types = [self __typeSuffixWithType:type];
    NSFileManager *fmgr = [NSFileManager defaultManager];
    for (NSString *scale in scales) {
        for (NSString *type in types) {
            NSString *fileName = [NSString stringWithFormat:@"%@%@.%@", name, scale, type];
            NSString *path = [directory stringByAppendingPathComponent:fileName];
            BOOL isDirecotry = NO;
            if ([fmgr fileExistsAtPath:path isDirectory:&isDirecotry]) {
                if (!isDirecotry) {
                    UIImage *image = [UIImage imageWithContentsOfFile:path];
                    if (image) {
                        return image;
                    }
                }
            }
        }
    }
    return nil;
}

- (NSArray *)__scaleSuffixWithScale:(NSUInteger)scale {
    if (scale != 0) {
        return @[[NSString stringWithFormat:@"@%@x", @(scale)]];
    } else {
        static NSArray *_scales = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSUInteger screenScale = (NSUInteger)UIScreen.mainScreen.scale;
            switch (screenScale) {
                case 1:
                    _scales = @[@"", @"@2x", @"@3x"];
                    break;
                case 2:
                    _scales = @[@"@2x", @"@3x", @""];
                    break;
                case 3:
                    _scales = @[@"@3x", @"@2x", @""];
                    break;
                default:
                    _scales = @[@"@3x", @"@2x", @""];
                    break;
            }
        });
        return _scales;
    }
}

- (NSArray *)__typeSuffixWithType:(NSString *)type {
    if (type) {
        return @[type];
    } else {
        return @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp", @"apng"];
    }
}

@end
