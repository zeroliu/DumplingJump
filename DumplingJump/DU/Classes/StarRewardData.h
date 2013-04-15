//
//  StarRewardData.h
//  CastleRider
//
//  Created by zero.liu on 4/15/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StarRewardData : NSObject
+(id) shared;
-(int) loadRewardStarNumWithGroupID:(int) groupID;
@end
