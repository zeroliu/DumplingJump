//
//  UserData.h
//  CastleRider
//
//  Created by LIU Xiyuan on 13-1-31.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface UserData : CCNode

@property (nonatomic, retain) NSMutableDictionary *userDataDictionary;
+(id) shared;
@end
