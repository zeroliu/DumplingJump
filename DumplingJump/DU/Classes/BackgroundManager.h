//
//  BackgroundManager.h
//  CastleRider
//
//  Created by zero.liu on 4/19/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface BackgroundManager : CCNode
+ (id) shared;

- (void) addBackgroundToLayer;
- (void) reset;
- (void) updateBackgroundPosition:(ccTime)deltaTime;
- (void) updateBackgroundObjectPosition:(ccTime)deltaTime;
- (void) speedUpWithScale:(int)scale interval:(float)time;
- (void) shakeBackgroundWithX:(float)amountX y:(float)amountY duration:(float)time;
@end
