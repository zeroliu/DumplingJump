//
//  DUTableView.h
//  DumplingJump
//
//  Created by LIU Xiyuan on 12-12-9.
//  Copyright (c) 2012年 CMU ETC. All rights reserved.
//

#import "CCNode.h"
#import "CCScrollView.h"
@interface DUTableView : CCScrollView <CCScrollViewDelegate>

-(id) initWithSize:(CGSize)viewSize dataSource:(NSDictionary *)dataSource;

@end
