//
//  NSString+HXImage.h
//  HXImage
//
//  Created by 冷秋 on 2018/7/3.
//  Copyright © 2018年 unique. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HXImage)

@property (nonatomic, strong, readonly) NSString *hx_MD5;

@property (nonatomic, assign, readonly) BOOL hx_containsScale;
@property (nonatomic, assign, readonly) NSUInteger hx_scale;
@property (nonatomic, strong, readonly) NSString *hx_removeScale;

@property (nonatomic, assign, readonly) BOOL hx_containsType;
@property (nonatomic, strong, readonly) NSString *hx_type;
@property (nonatomic, strong, readonly) NSString *hx_removeType;

@end
