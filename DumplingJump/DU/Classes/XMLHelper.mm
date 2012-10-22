//
//  XMLHelper.mm
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-10-21.
//  Copyright (c) 2012 CMU ETC. All rights reserved.
//

#import "XMLHelper.h"
#import "DDXML.h"
@implementation XMLHelper

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[XMLHelper alloc] init];
    }
    return shared;
}

-(id) init
{
    if (self = [super init])
    {
        [self testXML];
    }
    
    return self;
}

-(void) testXML
{
    DDXMLDocument *xmlDoc;
    NSError *err = nil;
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CA_level1" ofType:@"xml"] encoding:NSUTF8StringEncoding error:&err];
    xmlDoc = [[DDXMLDocument alloc] initWithXMLString:content options:0 error:&err];
    if (xmlDoc == nil)
    {
        if (err)
        {
            NSLog(@"error parse to xmldoc, %@", [err description]);
        }
    }
    NSArray *results = [xmlDoc nodesForXPath:@"//time" error:&err];
    if (err)
    {
        NSLog(@"%@",[err localizedDescription]);
    }
    for (DDXMLElement *time in results)
    {
        NSString *mytime = [time stringValue];
        NSLog(mytime);
    }
}

@end
