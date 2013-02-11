//
//  DUButtonFactory.h
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-10.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DUButtonFactory : CCNode

+(id) createButtonWithPosition:(CGPoint)pos image:(NSString *)imageName;

@end
