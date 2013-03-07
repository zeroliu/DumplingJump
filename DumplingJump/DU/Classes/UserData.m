//
//  UserData.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-1-31.
//  Copyright (c) 2013年 CMU ETC. All rights reserved.
//

#import "UserData.h"
#import "XMLHelper.h"
#import "WorldData.h"
#import "Constants.h"
@implementation UserData
@synthesize
    userDataDictionary = _userDataDictionary;

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
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath] && ![[[((WorldData *)[WorldData shared]) loadDataWithAttributName:@"debug"] objectForKey:@"forceReloadUserData"] boolValue])
    {
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        self.userDataDictionary = (NSMutableDictionary *) [NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    } else
    {
        self.userDataDictionary = [[XMLHelper shared] loadUserDataWithXML:@"Editor_userData"];
    }
    
    if (!self.userDataDictionary)
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
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:self.userDataDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    if (plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"writting successfully: \n %@", self.userDataDictionary);
    } else
    {
        NSLog(@"%@",error);
        [error release];
    }
}


@end
