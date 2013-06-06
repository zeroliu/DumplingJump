//
//  TutorialManager.h
//  CastleRider
//
//  Created by zero.liu on 5/26/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TutorialManager : NSObject

+ (id) shared;

- (BOOL) isInTutorial;
- (BOOL) isInGameTutorial;
- (BOOL) isInStoreTutorial;

- (void) startMoveTutorial;
- (void) startJumpTutorial;
- (void) startPowerupTutorial;
- (void) startAddthingTutorial;
- (void) startBombTutorial;
- (void) startStoreTutorialPartOne;
- (void) startStoreTutorialPartTwo;
- (void) resetTutorial;
- (void) finishTutorial;
@end
