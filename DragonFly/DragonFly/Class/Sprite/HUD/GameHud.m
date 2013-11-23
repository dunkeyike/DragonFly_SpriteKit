//
//  GameHud.m
//  DragonFly
//
//  Created by Dunkey on 2013. 11. 11..
//  Copyright (c) 2013년 Dunkey. All rights reserved.
//

#import "GameHud.h"

@implementation GameHud

- (void) setupNode {
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Copperplate"];
    label.text = @"Score";
    label.fontColor = [SKColor redColor];
    label.fontSize = 16;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    label.position = CGPointMake(200, 550);
    [self addChild:label];
}
@end
