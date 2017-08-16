//
//  UIViewController+BackButtonHandler.h
//  HybridDemo
//
//  Created by DianQK on 2017/5/24.
//  Copyright © 2017年 DianQK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>

@optional

// Override this method in UIViewController derived class to handle 'Back' button click

-(BOOL)navigationShouldPopOnBackButton;

@end

@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end
