//
//  KBImageManager.m
//  Kuber
//
//  Created by Kuber on 16/3/30.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "KBImageManager.h"
#import "NSBundle+Scale.h"
#import "NSString+Scale.h"
#import "NSObject+MRC.h"


@interface KBImageManager ()

@property (nonatomic, strong) NSMutableDictionary *imageDic;
@property (nonatomic, assign) BOOL isEnum;
@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation KBImageManager

+ (instancetype)defaultManager {
    static KBImageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KBImageManager alloc]init];
        [manager addRunLoopObserver];
        manager.isEnum = NO;
    });
    return manager;
}


- (UIImage *)imageWithName:(NSString *)name {
	// read from RAM
	UIImage *image = [self.imageDic valueForKey:name];
	
	if(image) {
		return image;
	}
	
	// read ROM
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
	UIImage *storeimage = [[UIImage alloc] initWithData:data scale:scale];
	
	// save to RAM
	[self.imageDic setObject:storeimage forKey:name];
	
	return storeimage;
}

#pragma mark - Run loop 

- (void)addRunLoopObserver {
    CFRunLoopObserverRef oberver= CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry:
                break;
            case kCFRunLoopBeforeTimers:
                break;
            case kCFRunLoopBeforeSources:
                break;
            case kCFRunLoopBeforeWaiting:
                [self selfRemoveRetainCountIsOne];
                break;
            case kCFRunLoopAfterWaiting:
                break;
            case kCFRunLoopExit:
                break;
            default:
                break;
        }
    });

    
    CFRunLoopAddObserver(CFRunLoopGetMain(), oberver, kCFRunLoopCommonModes);
}

- (void)selfRemoveRetainCountIsOne {
    dispatch_async(self.queue, ^{
        [self.lock lock];
        if(self.isEnum) return;
        NSMutableArray *keyArr = @[].mutableCopy;
        self.isEnum = YES;
        [self.imageDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSObject * _Nonnull obj, BOOL * _Nonnull stop) {
			NSInteger count = obj.obj_retainCount;
            if(count == 2) {
                [keyArr addObject:key];
            }
        }];
        [keyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.imageDic removeObjectForKey:obj];
        }];
        self.isEnum = NO;
        [self.lock unlock];
    });
}



- (NSLock *)lock {
	if(!_lock) {
		_lock = [NSLock new];
	}
	return _lock;
}


- (NSMutableDictionary *)imageDic {
	if (!_imageDic) {
		_imageDic = [NSMutableDictionary dictionary];
	}
	return _imageDic;
}

- (dispatch_queue_t)queue {
	if (_queue == NULL) {
		_queue = dispatch_queue_create("com.huaxu.image", DISPATCH_QUEUE_CONCURRENT);
	}
	return _queue;
}

@end
