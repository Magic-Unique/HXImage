//
//  WeakReference.h
//  Kuber
//
//  Created by Kuber on 16/4/29.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^WeakReference)(void);

WeakReference makeWeakReference(id object);

id weakReferenceNonretainedObjectValue(WeakReference ref);
