//
//  NSString+AddScale.m
//  Kuber
//
//  Created by Kuber on 16/3/30.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "NSString+AddScale.h"

@implementation NSString (AddScale)

- (NSString *)stringByAppendingScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

@end
