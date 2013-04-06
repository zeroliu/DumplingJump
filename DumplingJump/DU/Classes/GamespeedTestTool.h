//
//  GamespeedTestTool.h
//  CastleRider
//
//  Created by zero.liu on 4/5/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "cocos2d.h"

@interface GamespeedTestTool : CCNode
+(id) shared;
-(void) reset;
-(void) updateUI;
-(void) setEnable:(BOOL)isEnabled;
@end
