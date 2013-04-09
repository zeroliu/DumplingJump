//
//  PowderInfo.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-3-3.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "PowderInfo.h"


@implementation PowderInfo
@synthesize
countdownLabel = _countdownLabel,
countdown = _countdown,
addthing = _addthing;

- (id) initWithAddthing: (id)addthing label:(CCLabelBMFont *)label countdown:(float)countdown;
{
    if (self = [super init])
    {
        self.countdownLabel = label;
        self.countdown = countdown;
        self.addthing = addthing;
    }
    
    return self;
}

- (void)dealloc
{
    [_countdownLabel release];
    [_addthing release];
    [super dealloc];
}
@end
