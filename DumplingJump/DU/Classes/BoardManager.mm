#import "BoardManager.h"

@interface BoardManager()
@property (nonatomic, retain) DUPhysicsObject *board;
@end

@implementation BoardManager

@synthesize board = _board;

+(id) shared
{
    static id shared = nil;
    if (shared == nil)
    {
        shared = [[BoardManager alloc] init];
    }
    return shared;
}

-(id) createBoardWithSpriteName:(NSString *)fileName position:(CGPoint) pos
{
    //Remove the existing board
    if (self.board != nil) [self.board release];
    //Create new board with the board name and the position
    self.board = [[Board alloc] initBoardWithBoardName:BOARD spriteName:fileName position:pos];
    //Add the board to the view
    [self.board addChildTo:BATCHNODE];
    return self.board;
}

-(id) getBoard
{
    return self.board;
}

@end
