//
//  OutlineLabel.m
//  CastleRider
//
//  Created by zero.liu on 4/9/13.
//  Copyright (c) 2013 CMU ETC. All rights reserved.
//

#import "OutlineLabel.h"
#import "Constants.h"

@interface OutlineLabel()
{
    float _strokeSize;
    UIColor *_strokeColor;
}

@end

@implementation OutlineLabel

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _strokeSize = 0;
        _strokeColor = [[UIColor whiteColor] retain];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)fontColor strokeSize:(int)strokeSize strokeColor:(UIColor *)strokeColor sizeToFit: (BOOL)isSizeToFit
{
//    if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
//    {
//        [self setFont:font];
//        [self setText:text];
//        [self setTextColor:fontColor];
//        if (isSizeToFit)
//        {
//            [self sizeToFit];
//        }
//    }
//    else
//    {
//        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
//        [string addAttributes:@{NSStrokeWidthAttributeName:[NSNumber numberWithFloat:strokeSize * -1],
//   NSStrokeColorAttributeName:strokeColor,
//NSForegroundColorAttributeName:fontColor
//         } range:NSMakeRange(0, [string length])];
//        
//        [self setFont:font];
//        [self setAttributedText:string];
//        if (isSizeToFit)
//        {
//            [self sizeToFit];
//        }
//        //Increase the size of the starNumLabel frame in order to see the last part of the stroke
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,self.frame.size.width+5, self.frame.size.height);
//        
//        [string release];
//    }
    
    [self setFont:font];
    [self setText:text];
    [self setTextColor:fontColor];
    if (isSizeToFit)
    {
        [self sizeToFit];
    }
    
    if (_strokeColor != nil)
    {
        [_strokeColor release];
        _strokeColor = nil;
    }
    _strokeColor = [strokeColor copy];
    _strokeSize = strokeSize;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,self.frame.size.width+5, self.frame.size.height);
    
}

- (void) drawTextInRect:(CGRect)rect
{
//    if (SYSTEM_VERSION_LESS_THAN(@"6.0"))
//    {
//        [super drawTextInRect:rect];
//        return;
//    }
//    
//    // We rely on stroke being set on the attributed text, if it isn't just render
//    // this as usual.
//    if (![[self attributedText] length])
//    {
//        [super drawTextInRect:rect];
//        return;
//    }
//    
//    // Retrieve the stroke width, assuming there is only a single stroke width set.
//    NSRangePointer pointer = nil;
//    CGFloat strokeWidth = [[[self attributedText] attribute:NSStrokeWidthAttributeName
//                                                    atIndex:0
//                                             effectiveRange:pointer] floatValue];
//    
//    // Retrieve the stroke colour, assuming there is only one stroke colour set.
//    UIColor *strokeColor = [[self attributedText] attribute:NSStrokeColorAttributeName
//                                                    atIndex:0
//                                             effectiveRange:pointer];
//    
//    // If width is zero or positive (positive is non-filled outlines!) or no
//    // stroke colour is set. Render this as usual.
//    if (strokeWidth >= 0 || !strokeColor)
//    {
//        [super drawTextInRect:rect];
//        return;
//    }
//    
//    // Store our original attributed string.
//    NSAttributedString *original = [self attributedText];
//    
//    // Create a copy
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
//                                                   initWithAttributedString:[self attributedText]];
//    
//    // Select the entire string.
//    NSRange allCharacters = NSMakeRange(0, [attributedString length]);
//    
//    // Set the foreground colour the same as the outline.
//    [attributedString addAttribute:NSForegroundColorAttributeName
//                             value:strokeColor
//                             range:allCharacters];
//    
//    // Draw this text (outline and text in same colour)
//    [self setAttributedText:attributedString];
//    [super drawTextInRect:rect];
//    
//    // Create a new string, this with the text colour of the original
//    attributedString = [[NSMutableAttributedString alloc]
//                        initWithAttributedString:original];
//    
//    // But set the stroke colour to transparent (this makes the offset
//    // and spacing exactly right)
//    [attributedString addAttribute:NSStrokeColorAttributeName
//                             value:[UIColor clearColor]
//                             range:allCharacters];
//    
//    // Draw this text (normal text colour, transparent outline)
//    [self setAttributedText:attributedString];
//    [super drawTextInRect:rect];
//    
//    // Revert the attributed text to the original.
//    [self setAttributedText:original];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    //Draw the text without an outline
//    [super drawTextInRect:rect];
    [super drawTextInRect:CGRectMake(rect.origin.x+1, rect.origin.y+0.4, rect.size.width, rect.size.height)];
    
    CGImageRef alphaMask = NULL;
    
    alphaMask = CGBitmapContextCreateImage(context);
    
    //Outline width
    CGContextSetLineWidth(context, _strokeSize);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    //Set the drawing method to stroke
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    
    //Outline color
    self.textColor = _strokeColor;
    
    // notice the +1 for the y-coordinate. this is to account for the face that outline appears to be thicker on top
    [super drawTextInRect:CGRectMake(rect.origin.x+1, rect.origin.y, rect.size.width, rect.size.height+2)];
    
    // Draw the saved image over the outline
    // and invert everything because CoreGraphics works with an inverted coordinate system
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, rect, alphaMask);
    
    //Clean up
    CGImageRelease(alphaMask);
}

- (void)dealloc
{
    [_strokeColor release];
    _strokeColor = nil;
    [super dealloc];
}

@end
