//
//  KBImageManager.m
//  Kuber
//
//  Created by Kuber on 16/3/30.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "KBImageManager.h"
#import "NSBundle+KBSCaleArray.h"
#import "NSString+AddScale.h"
#import "NSMutableDictionary+WeakReference.h"

@interface KBImageManager()

@property (nonatomic, strong) NSMutableDictionary *imageBuff;

@end

@implementation KBImageManager

+ (instancetype)defaultManager {
    static KBImageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (UIImage *)getImageWithName:(NSString *)name {
	
    UIImage *image = [self.imageBuff weak_getObjectForKey:name];
    if(image) {
        return image;
    }
	
    NSString *res = name.stringByDeletingPathExtension;
    NSString *ext = name.pathExtension;
    NSString *path = nil;
    CGFloat scale = 1;
    
    // If no extension, guess by system supported (same as UIImage).
    NSArray *exts = ext.length > 0 ? @[ext] : @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp", @"apng"];
    NSArray *scales = [NSBundle scaleArray];
    for (int s = 0; s < scales.count; s++) {
        scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = [res stringByAppendingScale:scale];
        for (NSString *e in exts) {
            path = [[NSBundle mainBundle] pathForResource:scaledName ofType:e];
            if (path) break;
        }
        if (path) break;
    }
    if (path.length == 0) return nil;
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) return nil;
    UIImage *storeImage = [[UIImage alloc] initWithData:data scale:scale];
    [self.imageBuff weak_setObject:storeImage forKey:name];
    
    return storeImage;

}
- (NSMutableDictionary *)imageBuff {
    if(!_imageBuff) {
        _imageBuff = [NSMutableDictionary dictionary];
    }
    return _imageBuff;
}

@end
