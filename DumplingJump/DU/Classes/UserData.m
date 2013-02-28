//
//  UserData.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-1-31.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "UserData.h"
#import "XMLHelper.h"
@implementation UserData
@synthesize
    isMusicMuted = _isMusicMuted,
    isSFXMuted = _isSFXMuted,
    dataDictionary = _dataDictionary;

+ (id) shared
{
    static id shared = nil;
    
    if (shared == nil)
    {
        shared = [[UserData alloc] init];
    }
    
    return shared;
}

- (id) init
{
    if (self = [super init])
    {
        [self loadUserData];
        _isMusicMuted = NO;
        _isSFXMuted = NO;
    }
    
    return self;
}

- (void) loadUserData
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"UserData.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        self.dataDictionary = (NSMutableDictionary *) [NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    } else
    {
        self.dataDictionary = [[XMLHelper shared] loadUserDataWithXML:@"Editor_userData"];
    }
    
    if (!self.dataDictionary)
    {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    } else
    {
        NSLog(@"Loading successfully");
    }
}

-(void) saveUserData
{
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"UserData.plist"];
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


@end
