//
//  EquipmentData.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-9.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "EquipmentData.h"
#import "XMLHelper.h"
@implementation EquipmentData
@synthesize dataDictionary = _dataDictionary;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[EquipmentData alloc] init];
    }
    
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self loadEquipmentData];
        //TODO: Load user data
    }
    return self;
}

- (void) loadEquipmentData
{
    self.dataDictionary = [[XMLHelper shared] loadEquipmentDataWithXML:@"Editor_equipment"];
}

- (void)dealloc
{
    [_dataDictionary release];
    [super dealloc];
}

@end
