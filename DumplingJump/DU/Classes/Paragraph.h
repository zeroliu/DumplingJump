//
//  Paragraph.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-19.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "CCNode.h"
#import "Sentence.h"
@interface Paragraph : CCNode

-(void) addSentence: (Sentence *)sentence;
-(id) getSentenceAtIndex: (int)index;
-(int) countSentencesNum;
@end
