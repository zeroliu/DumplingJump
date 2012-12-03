//
//  Star.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-11-12.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Star.h"

@implementation Star
@synthesize name=_name, width = _width, starLines = _starLines;

-(id) initEmptyStar
{
    if (self = [super init])
    {
        NSMutableArray *tmp = [NSMutableArray array];
        for (int i=0; i<9; i++)
        {
            NSMutableArray *line = [[NSMutableArray alloc] init];
            for (int j=0; j<9; j++)
            {
                [line addObject:@"0"];
            }
            [tmp addObject:line];
        }
        self.starLines = [[NSArray alloc] initWithArray:tmp];
    }
    
    return self;
}

-(NSString *) description
{
    NSString *res;
    NSString *starInfo = @"";
    res = [NSString stringWithFormat: @"\nName = %@\nWidth = %d", self.name, self.width];
    for (NSMutableArray *line in self.starLines)
    {
        for (NSString *slot in line)
        {
            starInfo = [NSString stringWithFormat: @"%@%@", starInfo, (([slot isEqualToString:@"1"])?(@"1"):(@" "))];
        }
        starInfo = [NSString stringWithFormat: @"%@\n", starInfo];
    }
    return [NSString stringWithFormat:@"%@\n%@\n", res, starInfo];
}
@end

