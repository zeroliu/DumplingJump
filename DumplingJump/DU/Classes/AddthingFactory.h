//
//  AddthingFactory.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-8-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "DUFactory.h"

@interface AddthingFactory : DUFactory
@property (nonatomic, retain) NSDictionary *addthingDictionary;
+(id) shared;
- (NSString *) getCustomDataByName:(NSString *)objectName;
@end
