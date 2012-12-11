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
        
    }
    
    return self;
}

-(void) loadEquipmentData
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"EquipmentData.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        self.dataDictionary = (NSDictionary *) [NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    } else
    {
        self.dataDictionary = [[XMLHelper shared] loadEquipmentDataWithXML:@"Editor_equipment"];
    }
    
    if (!self.dataDictionary)
    {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    } else
    {
        NSLog(@"Loading successfully");
    }
}

-(void) saveEquipmentData
{
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"EquipmentData.plist"];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:self.dataDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    if (plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"writting successfully: \n %@", self.dataDictionary);
    } else
    {
        NSLog(@"%@",error);
        [error release];
    }
}

- (void)dealloc
{
    [_dataDictionary release];
    [super dealloc];
}

@end
