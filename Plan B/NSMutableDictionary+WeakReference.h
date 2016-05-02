//
//  NSMutableDictionary+WeakReference.h
//  Kuber
//
//  Created by Kuber on 16/4/29.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (WeakReference)

- (void)weak_setObject:(id)anObject forKey:(NSString *)aKey;

- (void)weak_setObjectWithDictionary:(NSDictionary *)dic;

- (id)weak_getObjectForKey:(NSString *)key;

@end
