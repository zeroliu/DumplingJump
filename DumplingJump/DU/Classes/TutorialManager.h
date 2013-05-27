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

- (void) startMoveTutorial;
@end
