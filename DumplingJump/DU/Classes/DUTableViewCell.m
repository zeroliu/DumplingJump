//
//  DUTableViewCell.m
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import "DUTableViewCell.h"


@implementation DUTableViewCell

- (id) initWithXib:(NSString *)xibName
{
    if (self = [super init])
    {
        self = (DUTableViewCell *)[[[[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil] objectAtIndex:0] retain];
    }
    
    return self;
}

- (void) setLayoutWithDictionary:(NSDictionary *)content
{
    
}

@end
