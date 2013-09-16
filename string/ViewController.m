//
//  ViewController.m
//  string
//
//  Created by Ryou Inoue on 2013/09/13.
//  Copyright (c) 2013年 Ryou Inoue. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "nnCALayer.h"

@interface ViewController ()

@property NSTimeInterval timestampBegan;
@property NSTimeInterval timestampRotationStart;
@property int rotationDirection;
@property CGPoint pointBegan;

- (void)stopRotation:(CGPoint)point;
- (void)startRotation:(CGPoint)point withEvent:(UIEvent *) event;
- (int)judgeRotationDirection:(CGPoint)point;

#define RIGHT_ROTATION 1
#define LEFT_ROTATION 2
#define ANIMATION_NAME @"ImageViewRotation"

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //タッチした時間と位置を保存
    UITouch *touch = [touches anyObject];
    _timestampBegan = event.timestamp;
    _pointBegan = [touch locationInView:self.view];
    [self stopRotation:_pointBegan];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"move\n");
    UITouch *touchMoved = [touches anyObject];
    CGPoint pointMoved = [touchMoved locationInView:self.view];
    // TODO:タッチ開始位置が範囲内だったら、なにもしない
    
    // 移動時のpointがlabelの範囲に入ったら、回転させる。
    [self startRotation:pointMoved
              withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    static const NSTimeInterval kFlickJudgeTimeInterval = 0.3;
    static const NSInteger kFlickMinimumDistance = 10;
    UITouch *touchEnded = [touches anyObject];
    CGPoint pointEnded = [touchEnded locationInView:self.view];
    NSInteger distanceHorizontal = ABS(pointEnded.x - _pointBegan.x);
    NSInteger distanceVertical = ABS(pointEnded.y - _pointBegan.y);
    if (kFlickMinimumDistance > distanceHorizontal && kFlickMinimumDistance > distanceVertical) {
//        [self stopRotation:pointEnded];
        //縦にも横にもあまり移動していなければタップ
//        NSString *message = @"タップ";
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:@"OK", nil];
//        [alert show];
        return;
    }
    NSTimeInterval timeBeganToEnded = event.timestamp - _timestampBegan;
    if (kFlickJudgeTimeInterval > timeBeganToEnded) {
        //フリックした場合の処理
//        NSString *message;
        //どの方向にフリックしたかを判定
//        if (distanceHorizontal > distanceVertical) {
//            if (pointEnded.x > _pointBegan.x) {
//                message = @"右フリック";
//            } else {
//                message = @"左フリック";
//            }
//        } else {
//            if (pointEnded.y > _pointBegan.y) {
//                message = @"下フリック";
//            } else {
//                message = @"上フリック";
//            }
//        }
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:@"OK", nil];
//        [alert show];
    }
}

/*
 * タップ時に、Labelのポイントであれば、停止させる。
 *
 */
- (void)stopRotation:(CGPoint) point
{
    CALayer *layer = self.string.layer;
    NSInteger distanceHorizontal = ABS(layer.position.x - point.x);
    NSInteger distanceVertial = ABS(layer.position.y - point.y);
    double distance = sqrt(pow(distanceHorizontal, 2) + pow(distanceVertial, 2));
    if (layer.bounds.size.width/2 > distance) {
//        [layer pauseAnimation:YES];
        
        CAAnimation *animation = [layer animationForKey:@"ImageViewRotation"];
        if (animation) {
            // 角度を計算
            NSTimeInterval diff = _timestampBegan - _timestampRotationStart;
            if (_rotationDirection == RIGHT_ROTATION) {
                diff = diff * (-1); // 角度をマイナスにする
            }
            layer.transform = CATransform3DMakeRotation(diff * M_PI, 0.0, 0.0, 1.0);;
            [layer removeAnimationForKey:@"ImageViewRotation"];
        }
    }
}

/*
 * タップ位置が動いた時に、Labelのポイントであれば、回転させる。
 *
 */
- (void)startRotation:(CGPoint)point withEvent:(UIEvent *) event
{
    CALayer *layer = self.string.layer;
    
    // 範囲外ならば、return
    if ((layer.frame.origin.x > point.x ||
        point.x > layer.frame.origin.x + layer.frame.size.width) ||
        (layer.frame.origin.y > point.y ||
         point.y > layer.frame.origin.y + layer.frame.size.height) ) {
        return;
    }
    
    // 回転する向きを決める
    int direction = [self judgeRotationDirection:point];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    // すでにアニメーションが登録されているかチェック
    CAAnimation *rotationAnimation = [layer animationForKey:@"ImageViewRotation"];
    
    // アニメーションがなければ、作成して追加。あれば、更新して再開。
    if (rotationAnimation == nil) {
        animation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
        if (direction == RIGHT_ROTATION) {
            animation.toValue = [NSNumber numberWithFloat:M_PI * 2.0 * (-1)];
        }
        // これを設定しなければanimationDidStop:finished:は呼ばれない。
        animation.delegate = self;
        animation.duration = 2;             // 2秒で360度回転
        animation.repeatCount = 1;          // 1度実施s
        animation.cumulative = YES;         // 効果を累積
        animation.removedOnCompletion = NO; // 回転のあともとに戻さない
        animation.fillMode = kCAFillModeForwards; //同上
        [layer pauseAnimation:NO];
        [layer addAnimation:animation forKey:@"ImageViewRotation"];
        _timestampRotationStart = event.timestamp;
        _rotationDirection = direction;
    }
}

/*
 * 回転させるか判定する。
 * 回転出来る場合は、回転方向を返す。
 * @return RIGHT_ROTATION:右回り LEFT_ROTATION:左回り
 */
- (int)judgeRotationDirection:(CGPoint) point
{
#define WIDTH 0
#define HEIGHT 1
    // 象限 * frameに近い方向で、回転方向を決めるテーブル
    int directionTable [4][2] = {
        {LEFT_ROTATION, RIGHT_ROTATION},
        {RIGHT_ROTATION, LEFT_ROTATION},
        {LEFT_ROTATION, RIGHT_ROTATION},
        {RIGHT_ROTATION, LEFT_ROTATION},
    };
    
    CALayer *layer = self.string.layer;
    
    // pointのlabel内での象限を判定
    // anchorPoint の 右下を第1象限とし右回りに2〜4とする。
    int quadrant = 0;
    if (layer.position.x < point.x && layer.position.y < point.y) {
        quadrant = 1;
    } else if (layer.position.x > point.x && layer.position.y < point.y) {
        quadrant = 2;
    } else if (layer.position.x > point.x && layer.position.y > point.y) {
        quadrant = 3;
    } else {
        quadrant = 4;
    }
    
    // 縦横比を考慮
    CGFloat ratio = layer.frame.size.width / layer.frame.size.height;

    // frameに近い方向を検知する
    CGFloat minDistWidth, minDistHeight;
    for (int i = 0; i < 2; i++) {
        minDistWidth = ABS(layer.frame.origin.x - point.x);
        if (minDistWidth > layer.frame.size.width / 2) {
            minDistWidth = ABS(layer.frame.origin.x + layer.frame.size.width - point.x);
        }

        minDistHeight = ABS(layer.frame.origin.y - point.y);
        if (minDistHeight > layer.frame.size.height / 2) {
            minDistHeight = ABS(layer.frame.origin.y + layer.frame.size.height - point.y);
        }
    }
    
    int minWidthOrHeight;
    if (minDistWidth * ratio > minDistHeight) {
        minWidthOrHeight = HEIGHT;
    }
    else {
        minWidthOrHeight = WIDTH;
    }
    
    // 方向検知    
    int retVal = directionTable[quadrant - 1][minWidthOrHeight];
    NSLog(@"quadrant=%d, minWidthOrHeight=%d, retVal=%d\n",quadrant, minWidthOrHeight, retVal);
    return retVal;
}

/*
 * ボタンがあったときは・・・
 */
- (IBAction)kaiten:(id)sender
{
    CALayer *layer = self.string.layer;
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.toValue = [NSNumber numberWithFloat:M_PI / 2.0];
    animation.duration = 0.5;           // 0.5秒で90度回転
    animation.repeatCount = MAXFLOAT;   // 無限に繰り返す
    animation.cumulative = YES;         // 効果を累積
    animation.removedOnCompletion = NO; // 回転のあともとに戻さない
    animation.fillMode = kCAFillModeForwards; //同上
    [layer pauseAnimation:NO];
    [layer addAnimation:animation forKey:@"ImageViewRotation"];
}

/**
 * アニメーション開始時
 */
- (void)animationDidStart:(CAAnimation *)theAnimation
{
    NSLog(@"開始");
}

/**
 * アニメーション終了時
 */
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    CALayer *layer = self.string.layer;
    
    // 複数のアニメーションのdelegateに同じオブジェクトを設定している場合には、
    // 引数animが処理対象のアニメーションと一致するかをチェックし、
    // 一致した場合にのみ処理を行う。
    if (theAnimation == [layer animationForKey:@"ImageViewRotation"]) {
        // アニメーション終了時の状態で静止させるためには
        // アニメーションのtoValueプロパティを使用すればよい。
//        CABasicAnimation *animation = (CABasicAnimation *)theAnimation;
//        layer.transform = [animation.toValue CATransform3DValue];
        [layer removeAnimationForKey:@"ImageViewRotation"];
    }
}

@end
