//
//  Paragraph.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-19.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "Paragraph.h"
@interface Paragraph()
@property (nonatomic, retain) NSMutableArray *sentences;
@end

@implementation Paragraph
@synthesize sentences = _sentences;

-(id) init
{
    if (self = [super init])
    {
        self.sentences = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) addSentence: (Sentence *)sentence
{
    [self.sentences addObject:sentence];
}

-(id) getSentenceAtIndex: (int)index
{
    return [self.sentences objectAtIndex:index];
}

-(int) countSentencesNum
{
    return [self.sentences count];
}

@end
