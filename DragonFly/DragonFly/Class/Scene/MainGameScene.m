//
//  MyScene.m
//  shooting
//
//  Created by Dunkey on 2013. 11. 7..
//  Copyright (c) 2013년 Dunkey. All rights reserved.
//

#import "MainGameScene.h"

@interface MainGameScene() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode      *player;
@property (nonatomic) NSTimeInterval    lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval    lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval    lastbulletTimeInterval;
@property (nonatomic) NSTimeInterval    lastbulletUpdateTimeInterval;
@property (nonatomic) int               monsterDestroyed;
@property (nonatomic) BOOL              isBossMode;
@end

static const uint32_t playerCategory            = 0x1 << 0;
static const uint32_t monsterCategory           = 0x1 << 1;
static const uint32_t bulletCategory            = 0x1 << 2;

// 벡터 계산 인라인 함수
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMulti(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength (CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint rwNormalize (CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}


@implementation MainGameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.isBossMode = NO;
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        SKSpriteNode *bgNode = [SKSpriteNode spriteNodeWithImageNamed:@"bg_01.png"];
        bgNode.size = self.size;
        bgNode.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:bgNode];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player.png"];
        self.player.position = CGPointMake(self.size.width/2, 100);
        self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.player.size.width/4, self.player.size.height/4)];
        self.player.physicsBody.dynamic = YES;
        self.player.physicsBody.categoryBitMask  = playerCategory;
        self.player.physicsBody.contactTestBitMask  = monsterCategory;
        self.player.physicsBody.collisionBitMask = 0;
        self.player.physicsBody.usesPreciseCollisionDetection = YES;
        
        [self addChild:self.player];
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
 
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    self.player.position = CGPointMake(location.x, self.player.position.y);
}

-(void)update:(CFTimeInterval)currentTime {
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithTimeIntervalLastUpdate:timeSinceLast];
    
}

- (void) updateWithTimeIntervalLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    self.lastbulletTimeInterval += timeSinceLast;
    
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        if (self.isBossMode) {
            [self addBoss];
        } else {
            [self addMonster];
        }
        
    }
    if (self.lastbulletTimeInterval > 0.1) {
        self.lastbulletTimeInterval = 0;
        [self addBullet];
    }
}

- (void) addMonster {
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"enemy_small.png"];
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = bulletCategory | playerCategory;
    monster.physicsBody.collisionBitMask = 0;
    
    int minX = monster.size.width/2;
    int maxX = self.frame.size.width - monster.size.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random()%rangeX) + minX;
    
    monster.position = CGPointMake(actualX, self.frame.size.height + monster.size.height/2);
    [self addChild:monster];
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random()%rangeDuration) + minDuration;
    
    SKAction *actionMove = [SKAction moveTo:CGPointMake(actualX , -monster.size.width/2 ) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
//    SKAction *loseAction = [SKAction runBlock:^{
//        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
//        SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
//        [self.view presentScene:gameOverScene transition:reveal];
//    }];
//    [monster runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
}

-(void) addBullet {
    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"bullet_01_01.png"];
    bullet.position = CGPointMake(self.player.position.x, self.player.position.y + 50);
    
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bullet.size.width/2, bullet.size.height/2)];
    bullet.physicsBody.dynamic = YES;
    bullet.physicsBody.categoryBitMask  = bulletCategory;
    bullet.physicsBody.contactTestBitMask  = monsterCategory;
    bullet.physicsBody.collisionBitMask = 0;
    bullet.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:bullet];
    
    CGPoint offset = rwSub(CGPointMake(bullet.position.x, 1000), bullet.position);
    CGPoint direction = rwNormalize(offset);
    CGPoint shootAmount = rwMulti(direction, 1000);
    CGPoint realDest = rwAdd(shootAmount, bullet.position);
    
    float velocity = 480.0 / 1.0;
    float realMoveDuration = self.size.width / velocity;
    
    SKAction *actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [bullet runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    [self runAction:[SKAction playSoundFileNamed:@"se_attack.wav" waitForCompletion:NO]];
}
- (void) addBoss {
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"boss.png"];
    monster.size = CGSizeMake(self.size.width/2, self.size.height/2);
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = bulletCategory | playerCategory;
    monster.physicsBody.collisionBitMask = 0;
    
    int minX = monster.size.width/2;
    int maxX = self.frame.size.width - monster.size.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random()%rangeX) + minX;
    
    monster.position = CGPointMake(actualX, self.frame.size.height + monster.size.height/2);
    [self addChild:monster];
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random()%rangeDuration) + minDuration;
    
    SKAction *actionMove = [SKAction moveTo:CGPointMake(actualX , -monster.size.width/2 ) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];

}
-(void) collisionWithBullet:(SKSpriteNode *)bullet fromMonster:(SKSpriteNode *)monster {
    self.monsterDestroyed++;
    if (self.monsterDestroyed > 4) {
        self.isBossMode = YES;
    }
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"spark" ofType:@"sks"];
    SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    myParticle.particlePosition = bullet.position;
//    myParticle.particleBirthRate = 5;
    [self addChild:myParticle];
//    myParticle.particleLifetime = 0.5;
    [self performSelector:@selector(removeSpark) withObject:Nil afterDelay:0.5];
//    [self removeSpark];
    [self runAction:[SKAction playSoundFileNamed:@"baby_dragon_die.wav" waitForCompletion:NO]];
    [bullet removeFromParent];
    [monster removeFromParent];
}
- (void) removeSpark {
    for (SKEmitterNode *sks in [self children]) {
        if ([sks isKindOfClass:[SKEmitterNode class]]) {
            SKAction *alphaRemove = [SKAction fadeOutWithDuration:0.5];
            SKAction *remove = [SKAction removeFromParent];
            [sks runAction:[SKAction sequence:@[alphaRemove, remove]]];
        }
    }
}
-(void) collisionWithPlayer:(SKSpriteNode *)player fromMonster:(SKSpriteNode *)monster {
    NSLog(@"Hit");
}

-(void) didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & playerCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0) {
        [self collisionWithPlayer:(SKSpriteNode*)firstBody.node fromMonster:(SKSpriteNode *)secondBody.node];
    }
    
    
    if ((firstBody.categoryBitMask & monsterCategory) != 0 &&
        (secondBody.categoryBitMask & bulletCategory) != 0) {
            [self collisionWithBullet:(SKSpriteNode*)firstBody.node fromMonster:(SKSpriteNode *)secondBody.node];
    }
}

@end
