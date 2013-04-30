//
//  CameraEffects.h
//  CastleRider
//
//  Created by zero.liu on 4/30/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "cocos2d.h"

@interface CameraEffects : NSObject

+ (id) shared;

- (void) shakeCameraWithTarget:(CCNode *)target x:(float)amountX y:(float)amountY duration:(float)time;

- (void) updateCameraEffect:(float)dt;

@end
