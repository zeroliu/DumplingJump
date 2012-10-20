//
//  Sentence.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-19.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Sentence.h"
#import "Constants.h"
@implementation Sentence
@synthesize distance = _distance, words = _words;

-(id) initWithDistance: (float)theDistance Words: (NSArray *)theWords
{
    if (self = [super init])
    {
        self.distance = theDistance;
        self.words = [[NSArray alloc] initWithArray:theWords];
    }
    
    return self;
}


@end
