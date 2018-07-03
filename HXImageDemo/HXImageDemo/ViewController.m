//
//  ViewController.m
//  HXImageDemo
//
//  Created by 冷秋 on 2018/7/3.
//  Copyright © 2018年 unique. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+HXImage.h"
#import "NSObject+Dealloc.h"

@interface ViewController ()

@property (nonatomic, strong, readonly) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageView = [[UIImageView alloc] init];
    [self.view addSubview:_imageView];
    UIImage *image = [UIImage hx_imageNamed:@"tabbar_style@3x"];
    [image onDealloc:^{
        NSLog(@"UIImage has dealloc.");
    }];
    _imageView.image = image;
    [_imageView sizeToFit];
    _imageView.center = self.view.center;
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)]];
    _imageView.userInteractionEnabled = YES;
}

- (void)onClick:(id)sender {
    _imageView.image = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
