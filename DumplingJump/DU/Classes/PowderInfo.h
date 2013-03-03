//
//  PowderInfo.h
//  CastleRider
//
//  Created by LIU Xiyuan on 13-3-3.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PowderInfo : CCNode

@property (nonatomic, retain) CCLabelTTF *countdownLabel;
@property (nonatomic, assign) float countdown;
@property (nonatomic, retain) id addthing;
- (id) initWithAddthing: (id)addthing label:(CCLabelTTF *)label countdown:(float)countdown;
@end
