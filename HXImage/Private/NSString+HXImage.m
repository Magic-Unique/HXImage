//
//  NSString+HXImage.m
//  HXImage
//
//  Created by 冷秋 on 2018/7/3.
//  Copyright © 2018年 unique. All rights reserved.
//

#import "NSString+HXImage.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (HXImage)

- (NSString *)hx_MD5 {
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, length, bytes);
    return [self hx_stringFromBytes:bytes length:CC_MD5_DIGEST_LENGTH];
}

- (NSString *)hx_stringFromBytes:(unsigned char *)bytes length:(NSUInteger)length {
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++)
        [mutableString appendFormat:@"%02x", bytes[i]];
    return [NSString stringWithString:mutableString];
}

- (NSString *)hx_type {
    NSArray *item = [self componentsSeparatedByString:@"."];
    if (item.count > 1) {
        return item.lastObject;
    } else {
        return nil;
    }
}

- (BOOL)hx_containsType {
    return [self componentsSeparatedByString:@"."].count > 1;
}

- (NSString *)hx_removeType {
    return [self stringByDeletingPathExtension];
}

- (NSUInteger)hx_scale {
    NSString *name = self.stringByDeletingPathExtension;
    if ([name hasSuffix:@"@2x"]) {
        return 2;
    } else if ([name hasSuffix:@"@3x"]) {
        return 3;
    } else {
        return 0;
    }
}

- (BOOL)hx_containsScale {
    NSString *name = self.stringByDeletingPathExtension;
    return [name hasSuffix:@"@2x"] || [name hasSuffix:@"@3x"];
}

- (NSString *)hx_removeScale {
    NSString *type = self.pathExtension;
    NSString *name = self.stringByDeletingPathExtension;
    NSMutableArray *item = [[name componentsSeparatedByString:@"@"] mutableCopy];
    [item removeLastObject];
    name = [item componentsJoinedByString:@"@"];
    return [name stringByAppendingPathExtension:type];
}

@end
