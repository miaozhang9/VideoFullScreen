//
//  UITabBarController+Rotation.m
//  VideoFullScreen
//
//  Created by Miaoz on 2019/9/6.
//  Copyright © 2019 ShuXun. All rights reserved.
//

#import "UITabBarController+Rotation.h"

@implementation UITabBarController (Rotation)
- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}
@end
