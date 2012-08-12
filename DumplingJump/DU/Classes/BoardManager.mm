#import "BoardManager.h"

@implementation BoardManager

@synthesize board = _board;

-(id) createBoardWithBoardName:(NSString *)theName position:(CGPoint) pos
{
    //Remove the existing board
    if (self.board != nil) [self.board release];
    //Create new board with the board name and the position
    self.board = [[Board alloc] initBoardWithBoardName:theName position:pos];
    //Add the board to the view
    [self.board addChildTo:BATCHNODE];
    return self.board;
}

@end
