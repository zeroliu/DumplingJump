//
//  DUTableView.m
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-9.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "DUTableView.h"
#import "CCBReader.h"
@implementation DUTableView

-(id) initWithSize:(CGSize)viewSize dataSource:(NSDictionary *)dataSource
{
    if (self = [super initWithViewSize:viewSize])
    {
        [self configParams];
        [self createContainerWithDataSource:(NSDictionary *)dataSource];
    }
    
    return self;
}

-(void) configParams
{
    self.bounces = NO;
    self.minZoomScale = 1;
    self.maxZoomScale = 1;
    self.anchorPoint = ccp(0,1);
    self.direction = CCScrollViewDirectionVertical;
}

-(void) createContainerWithDataSource:(NSDictionary *)dataSource
{
    CCNode *containerContent = [CCNode node];
    CCNode *testCell = [CCBReader nodeGraphFromFile:@"UnlockedCell.ccbi"];
    testCell.position = ccp(0, 0);
    [containerContent addChild:testCell];
    testCell = [CCBReader nodeGraphFromFile:@"UnlockedCell.ccbi"];
    testCell.position = ccp(0, 100);
    [containerContent addChild:testCell];
    testCell = [CCBReader nodeGraphFromFile:@"UnlockedCell.ccbi"];
    testCell.position = ccp(0, 200);
    [containerContent addChild:testCell];
    testCell = [CCBReader nodeGraphFromFile:@"UnlockedCell.ccbi"];
    testCell.position = ccp(0, 300);
    [containerContent addChild:testCell];
    testCell = [CCBReader nodeGraphFromFile:@"UnlockedCell.ccbi"];
    testCell.position = ccp(0, 400);
    [containerContent addChild:testCell];
    NSLog(@"%g,%g", testCell.boundingBox.size.width, testCell.boundingBox.size.height);
    
    [containerContent setContentSize:CGSizeMake(testCell.boundingBox.size.width, testCell.boundingBox.size.height + 400)];
    for (id key in dataSource)
    {
        NSArray *itemArray = [dataSource objectForKey:key];
        for (NSDictionary *item in itemArray)
        {
            NSLog(@"Name: %@", [item objectForKey:@"name"]);
        }
    }
    
    self.container = containerContent;
}

- (void)dealloc
{
    [super dealloc];
}
@end
