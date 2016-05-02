//
//  NSObject+MRC.h
//  Kuber
//
//  Created by Kuber on 16/3/30.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MRC)

@property (nonatomic, assign, readonly) NSUInteger  obj_retainCount;

@end
