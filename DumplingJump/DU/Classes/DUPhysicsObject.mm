#import "DUPhysicsObject.h"
#define RATIO 32

@implementation DUPhysicsObject
@synthesize body = _body;

-(id) initWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody
{
    return [self initWithName:theName file:theFile body:theBody canResize:NO];
}

-(id) initWithName:(NSString *)theName file:(NSString *)theFile body:(b2Body *)theBody canResize:(BOOL) resize
{
    if (self = [super initWithName:theName file:theFile])
    {
        self.body = theBody;
        self.sprite = [CCSprite spriteWithSpriteFrameName:theFile];
        self.body->SetUserData(self);
        
        if (resize)
        {
            float scaleX = 1,scaleY = 1;
            if (self.body->GetFixtureList()->GetType() == b2Shape::e_circle)
            {
                b2CircleShape* circle = (b2CircleShape*) self.body->GetFixtureList()->GetShape();
                scaleX = 2*1.15f * circle->m_radius / self.sprite.boundingBox.size.width * RATIO;
                scaleY = 2*1.15f * circle->m_radius / self.sprite.boundingBox.size.height * RATIO;
            } else if (self.body->GetFixtureList()->GetType() == b2Shape::e_polygon) 
            {
                b2PolygonShape* poly = (b2PolygonShape*) self.body->GetFixtureList()->GetShape();
                scaleX = 2*1.15f * poly->m_vertices->x / self.sprite.boundingBox.size.width * RATIO;
                scaleY = 2*1.15f * poly->m_vertices->y / self.sprite.boundingBox.size.height * RATIO;
            }
            self.sprite.scaleX = max(scaleX, scaleY);
            self.sprite.scaleY = max(scaleX, scaleY);
        }
    }
    
    return self;
}

-(void) setUserData:(id)data;
{
    self.body->SetUserData(data);
}

-(void) resetPhysicsBodyPosition
{
    self.body->SetTransform(*new b2Vec2(self.sprite.position.x/RATIO, self.sprite.position.y/RATIO),0);
}

-(void) addChildTo: (CCNode *)node z:(int)zLayer
{
    [self resetPhysicsBodyPosition];
    [super addChildTo:node z:zLayer];
}

-(void) activate
{
    [super activate];
    self.body->SetActive(true);
    self.body->SetAwake(true);
    //TODO: Add info for contacts
}

-(void) deactivate
{
    [super deactivate];
    self.body->SetTransform(*new b2Vec2(0, 0),0);
    self.body->SetLinearVelocity(*new b2Vec2(0,0));
    self.body->SetAngularVelocity(0);
    self.body->SetActive(false);
    self.body->SetAwake(false);
    
    //TODO: Add info for contacts
//    NSLog(@"call DUPhysics deactive");
}

-(void) archive
{
    [super archive];
}

-(void) dealloc
{
    self.body->GetWorld()->DestroyBody(self.body);
    [super dealloc];
}

@end
