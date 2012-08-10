#import "GameLayer.h"

@interface BoardManager : DUPhysicsObject
@property (nonatomic, retain) DUPhysicsObject *board;

-(id) createBoardWithBoardName:(NSString *)theName position:(CGPoint) pos;
@end
