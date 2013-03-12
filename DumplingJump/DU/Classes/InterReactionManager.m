//
//  InterReactionManager.m
//  CastleRider
//
//  Created by zero.liu on 3/9/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "InterReactionManager.h"
#import "XMLHelper.h"

@interface InterReactionManager()
@property (nonatomic, retain) NSDictionary *interReactionDictionary;

@end

@implementation InterReactionManager
@synthesize interReactionDictionary = _interReactionDictionary;

+ (id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[InterReactionManager alloc] init];
    }
    
    return shared;
}

- (id) init
{
    if (self = [super init])
    {
        [self loadCollisionData];
    }
    
    return self;
}

- (void) loadCollisionData
{
    self.interReactionDictionary = [[XMLHelper shared] loadCollisionDataWithXML:@"Editor_interReactionData"];
}

- (NSString *) getInterReactionByAddthingName:(NSString *)addthingName forHeroStatus:(NSString *)statusName
{
    return [[self.interReactionDictionary objectForKey:statusName] objectForKey:addthingName];
}

- (void)dealloc
{
    [_interReactionDictionary release];
    _interReactionDictionary = nil;
    [super dealloc];
}
@end
