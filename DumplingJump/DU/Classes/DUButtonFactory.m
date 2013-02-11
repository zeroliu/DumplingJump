//
//  DUButtonFactory.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-10.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "DUButtonFactory.h"


@implementation DUButtonFactory

+(id) createButtonWithPosition:(CGPoint)pos image:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    if (image == nil)
    {
        NSLog(@"Warning, button image cannot be found!");
        return nil;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,image.size.width/2.0,image.size.height/2.0);
    button.center = pos;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    return button;
}

@end
