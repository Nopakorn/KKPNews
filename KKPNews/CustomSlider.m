//
//  CustomSlider.m
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/24/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(0, 0, 191, 5);
}

@end
