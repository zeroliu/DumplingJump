//
//  UserData.h
//  CastleRider
//
//  Created by LIU Xiyuan on 13-1-31.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface UserData : CCNode

@property (nonatomic, assign) BOOL isMusicMuted;
@property (nonatomic, assign) BOOL isSFXMuted;
@property (nonatomic, retain) NSMutableDictionary *dataDictionary;
+(id) shared;

@end
