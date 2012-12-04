//
//  StarManager.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "StarManager.h"
#import "LevelManager.h"
#import "XMLHelper.h"
@interface StarManager()
@property (nonatomic, retain) NSMutableDictionary *starDictionary;
@end

@implementation StarManager
@synthesize starDictionary = _starDictionary;
+(id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[StarManager alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        self.starDictionary = [[XMLHelper shared] loadStarDataWithXML:@"Star_editor"];
    }
    
    return self;
}

-(void) addStar:(Star *)star
{
    [self.starDictionary setObject:star forKey:star.name];
}

-(void) dropStar:(NSString *)starName AtSlot:(int)slot
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float xPosUnit = (winSize.width-5) / (float)SLOTS_NUM;
    float yPosUnit = (float)STAR_Y_INTERVAL;
    
    Star *star = [self.starDictionary objectForKey:starName];
    
    if (star != nil)
    {
        for (int i=0; i<SLOTS_NUM; i++)
        {
            NSArray *line = [star.starLines objectAtIndex:i];
            for (int j=0; j<SLOTS_NUM-slot; j++)
            {
                if ([[line objectAtIndex:j] isEqual:@"O"])
                {
                    [[LevelManager shared] dropAddthingWithName:@"STAR" atPosition:ccp(xPosUnit * (slot + j) + 5 + xPosUnit/2,600+(SLOTS_NUM-1-i)*yPosUnit)];
                }
            }
        }
    }
    
}

@end
