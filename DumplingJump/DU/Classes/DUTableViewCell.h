//
//  DUTableViewCell.h
//  CastleRider
//
//  Created by LIU Xiyuan on 13-2-19.
//  Copyright 2013年 CMU ETC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <UIKit/UIKit.h>

@interface DUTableViewCell : UITableViewCell
@property (assign) id parentTableView;

- (id) initWithXib:(NSString *)xibName;
- (void) setLayoutWithDictionary:(NSDictionary *)content;

@end
