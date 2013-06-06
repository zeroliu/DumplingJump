//
//  OutlineLabel.h
//  CastleRider
//
//  Created by zero.liu on 4/9/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OutlineLabel : UILabel

- (void) setText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)fontColor strokeSize:(int)strokeSize strokeColor:(UIColor *)strokeColor  sizeToFit: (BOOL)isSizeToFit;

@end
