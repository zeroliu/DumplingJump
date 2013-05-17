//
//  HighscoreLineManager.h
//  CastleRider
//
//  Created by zero.liu on 5/16/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HighscoreLine : NSObject

@property (nonatomic, retain) NSString*     playerID;
@property (nonatomic, retain) NSString*     nickName;
@property (nonatomic, assign) int           highDistance;

- (id) initWithDistance:(int)distance playerID:(NSString *)playerID nickName:(NSString *)nickName;

@end


@interface HighscoreLineManager : NSObject

@property (nonatomic, retain) NSMutableDictionary*      displayedlinesDictionary;
@property (nonatomic, retain) NSMutableDictionary*      registedlinesDictionary;

+ (id) shared;
- (void) registerHighDistance:(int)distance playerID:(NSString *)playerID nickName:(NSString *)nickName;
- (void) removeObservers;
- (void) reset;

@end
