#import "Common.h"
#import "Board.h"

@interface BoardManager : NSObject

@property (nonatomic, retain) DUPhysicsObject *board;

-(id) createBoardWithSpriteName:(NSString *)theName position:(CGPoint) pos;

@end
