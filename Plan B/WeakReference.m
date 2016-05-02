//
//  WeakReference.m
//  Kuber
//
//  Created by Kuber on 16/4/29.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "WeakReference.h"

WeakReference makeWeakReference(id object) {
    __weak id weakref = object;
    return ^{
        return weakref;
    };
}

id weakReferenceNonretainedObjectValue(WeakReference ref) {
	return ref ? ref() : nil;
}
