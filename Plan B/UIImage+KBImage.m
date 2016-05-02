//
//  UIImage+HXImage.m
//  Kuer
//
//  Created by Kuber on 16/3/30.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "UIImage+HXImage.h"
#import "KBImageManager.h"


@implementation UIImage (HXImage)

+ (UIImage *)hx_ImageNamed:(NSString *)name {
    if (name.length == 0) return nil;
    if ([name hasSuffix:@"/"]) return nil;
    
    KBImageManager *manager = [KBImageManager defaultManager];
    
    return [manager getImageWithName:name];
}

@end
