//
//  NSMutableDictionary+WeakReference.m
//  Kuber
//
//  Created by Kuber on 16/4/29.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "NSMutableDictionary+WeakReference.h"
#import "WeakReference.h"

@implementation NSMutableDictionary (WeakReference)

- (void)weak_setObject:(id)anObject forKey:(NSString *)aKey {
    [self setObject:makeWeakReference(anObject) forKey:aKey];
}

- (void)weak_setObjectWithDictionary:(NSDictionary *)dictionary {
    for (NSString *key in dictionary.allKeys) {
        [self setObject:makeWeakReference(dictionary[key]) forKey:key];
    }
}

- (id)weak_getObjectForKey:(NSString *)key {
    return weakReferenceNonretainedObjectValue(self[key]);
}

@end
