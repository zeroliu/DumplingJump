//
//  XMLHelper.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-21.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "CCNode.h"

@interface XMLHelper : CCNode
+(id) shared;

-(id) loadParagraphWithXML: (NSString *)fileName;
-(id) loadAddthingWithXML: (NSString *)fileName;
-(id) loadEffectWithXML: (NSString *)fileName;
-(id) loadReactionWithXML: (NSString *)fileName;
@end
