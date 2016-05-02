//
//  NSObject+MRC.m
//  Kuber
//
//  Created by Kuber on 16/3/30.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "NSObject+MRC.h"

@implementation NSObject (MRC)

- (NSUInteger)obj_retainCount {
	return [[self valueForKey:@"retainCount"] unsignedLongValue];
}

@end
