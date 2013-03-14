//
//  InterReactionManager.h
//  CastleRider
//
//  Created by zero.liu on 3/9/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InterReactionManager : NSObject

+ (id) shared;
- (NSString *) getInterReactionByAddthingName:(NSString *)addthingName forHeroStatus:(NSString *)statusName;
@end
