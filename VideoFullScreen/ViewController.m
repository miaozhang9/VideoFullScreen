//
//  ViewController.m
//  VideoFullScreen
//
//  Created by Miaoz on 2019/9/5.
//  Copyright © 2019 ShuXun. All rights reserved.
//

#import "ViewController.h"
#import <MovieousPlayer/MovieousPlayer.h>
#import <Reachability/Reachability.h>
#import <AVFoundation/AVFoundation.h>
static CGFloat AnimationDuration = 0.3;//旋转动画执行时间

@interface ViewController ()<
MovieousPlayerControllerDelegate
>

@property (nonatomic, nullable, strong) UIView *playerView;//播放器承载视图
@property (nonatomic, nullable, strong) UIButton *btnFullScreen;
@property (nonatomic, nullable, strong) UIButton *btnClose;
@property (nonatomic, nullable, strong) UIView *playerSuperView;//记录播放器父视图
@property (nonatomic, assign) CGRect playerFrame;//记录播放器原始frame
@property (nonatomic, assign) BOOL isFullScreen;//记录是否全屏
@property (strong, nonatomic) MovieousPlayerController *player;//播放容器
@property (nonatomic) UIInterfaceOrientation currentInterfaceOrientation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
#ifdef DEBUG
    MovieousPlayerController.logLevel = MPLogLevelError;
#else
    MovieousPlayerController.logLevel = MPLogLevelError;
#endif
    
   
    [self.playerView addSubview:self.btnFullScreen];
    [self.playerView addSubview:self.btnClose];
    [self.view addSubview:self.playerView];
//    [self reloadPlayer:[[NSBundle mainBundle] URLForResource:@"VRDemo" withExtension:@"m4v"]];
     [self reloadPlayer: [NSURL URLWithString:@"rtmp://58.200.131.2:1935/livetv/hunantv"]];
//    [self reloadPlayer: [NSURL URLWithString:@"rtmp://p.autostreets.com/live/shanghai-indoor"]];
  
    
    //开启和监听 设备旋转的通知
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)reloadPlayer:(NSURL *)URL {
    [_player.playerView removeFromSuperview];
    MovieousPlayerOptions *options = [MovieousPlayerOptions defaultOptions];
    options.liveStreaming = YES;
    options.allowMixAudioWithOthers = NO;
    options.decoderType = MovieousPlayerDecoderTypeHardware;
    _player = [MovieousPlayerController playerControllerWithURL:URL options:options];
    _player.maxBufferSize = 1024 * 1024;
    _player.scalingMode = MPScalingModeAspectFit;
    _player.delegate = self;
    _player.interruptInBackground = NO;
    //    _player.VRMode = YES;
    //    _player.gyroscopeEnabled = YES;
    //    _player.touchToMoveEnabled = YES;
    _player.interruptionOperation = MPInterruptionOperationStop;
    _player.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    _player.playerView.frame = self.playerView.frame;
    [self.playerView insertSubview:_player.playerView atIndex:0];
 
    [_player prepareToPlay];
    [_player play];
//    _volumeSlider.value = _player.volume;
}

- (void)movieousPlayerController:(MovieousPlayerController *)playerController playStateDidChange:(MPPlayerState)playState {
    switch (playState) {
        case MPPlayerStateIdle:
        case MPPlayerStatePaused:
        case MPPlayerStateCompleted:
            NSLog(@"MPPlayerStateCompleted");
        case MPPlayerStateStopped:
        case MPPlayerStateError:
//            _playButton.selected = NO;
            break;
        default:
//            _playButton.selected = YES;
            break;
    }
    NSLog(@"playState changed to %ld", (long)playState);
}

- (BOOL)movieousPlayerController:(MovieousPlayerController *)playerController playerBeginsToRetry:(NSUInteger)currentCount {
    NSLog(@"playerBeginsToRetry: %lu", (unsigned long)currentCount);
    return YES;
}

- (void)movieousPlayerController:(MovieousPlayerController *)playerController playFinished:(MPFinishReason)finishReason {
    dispatch_async(dispatch_get_main_queue(), ^{
//        self->_playButton.selected = NO;
    });
    NSLog(@"play finished because of %lu", (unsigned long)finishReason);
}

- (void)movieousPlayerControllerFirstVideoFrameRendered:(MovieousPlayerController *)playerController {
    NSLog(@"first video rendered");
}

- (void)movieousPlayerControllerFirstAudioFrameRendered:(MovieousPlayerController *)playerController {
    NSLog(@"first audio rendered");
}


//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            if (self.isFullScreen) {
                [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
            }
            
            NSLog(@"屏幕向左横置");
            break;
        case UIDeviceOrientationLandscapeRight:
            if (self.isFullScreen) {
                [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
            }
            
            NSLog(@"屏幕向右橫置");
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}
//最后在dealloc中移除通知 和结束设备旋转的通知
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}



#pragma mark - private method

- (void)fullScreenAction:(UIButton *)sender {
    
    if (self.isFullScreen) {//如果是全屏，点击按钮进入小屏状态
        [self changeToOriginalFrame];
       
    } else {//不是全屏，点击按钮进入全屏状态
        [self changeToFullScreen];
    }
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
    
}

- (void)closeAction:(UIButton *)sender {
    
 
    
}

- (void)changeToOriginalFrame {
    
    if (!self.isFullScreen) {
        return;
    }
    
    [UIView animateWithDuration:AnimationDuration animations:^{
        
        
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        self.playerView.frame = self.playerFrame;
        self.player.playerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.playerView.frame), CGRectGetHeight(self.playerView.frame));
        self.btnFullScreen.frame = CGRectMake(CGRectGetWidth(self.playerView.frame)-50, CGRectGetHeight(self.playerView.frame)-50, 40, 30);
    } completion:^(BOOL finished) {
        
        [self.playerView removeFromSuperview];
        
        [self.playerSuperView addSubview:self.playerView];
        self.isFullScreen = NO;
   
    }];
    
}

- (void)changeToFullScreen {
    if (self.isFullScreen) {
        return;
    }
    
    //记录播放器视图的父视图和原始frame值,在实际项目中，可能会嵌套子视图，所以播放器的superView有可能不是self.view，所以需要记录父视图
    self.playerSuperView = self.playerView.superview;
    self.playerFrame = self.playerView.frame;

    
    CGRect rectInWindow = [self.playerView convertRect:self.playerView.bounds toView:[UIApplication sharedApplication].keyWindow];
    [self.playerView removeFromSuperview];
    NSLog(@"rectInWindow%@",NSStringFromCGRect(rectInWindow));
    
    self.playerView.frame = rectInWindow;
    [[UIApplication sharedApplication].keyWindow addSubview:self.playerView];
       NSLog(@" self.playerView.frame%@",NSStringFromCGRect( self.playerView.frame));
    //执行旋转动画
    [UIView animateWithDuration:AnimationDuration animations:^{
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeRight) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        } else {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
        
       
        self.playerView.bounds = CGRectMake(0, 0, CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds), CGRectGetWidth([UIApplication sharedApplication].keyWindow.bounds));
        self.playerView.center = CGPointMake(CGRectGetMidX([UIApplication sharedApplication].keyWindow.bounds), CGRectGetMidY([UIApplication sharedApplication].keyWindow.bounds));
        
        self.player.playerView.frame =  CGRectMake(0, 0, CGRectGetHeight(self.playerView.frame), CGRectGetWidth(self.playerView.frame));
        self.btnFullScreen.frame = CGRectMake(CGRectGetHeight(self.playerView.frame)-50, CGRectGetWidth(self.playerView.frame)-50, 40, 30);
//        self.player.playerView.center =  CGPointMake(CGRectGetMidX([UIApplication sharedApplication].keyWindow.bounds), CGRectGetMidY([UIApplication sharedApplication].keyWindow.bounds));
        
    } completion:^(BOOL finished) {
        
        self.isFullScreen = YES;
         
    }];
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        [self setOrientationLandscapeConstraint:orientation];
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        [self setOrientationPortraitConstraint];
    }
}

- (void)setOrientationLandscapeConstraint:(UIInterfaceOrientation)orientation {
    
    [self toOrientation:orientation];
}

- (void)setOrientationPortraitConstraint {
    
    [self toOrientation:UIInterfaceOrientationPortrait];
}

- (void)toOrientation:(UIInterfaceOrientation)orientation {
    
    // 获取到当前状态条的方向,在iOS13之后无法使用此方法改变状态栏方向和使用
//    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
//    // 判断如果当前方向和要旋转的方向一致,那么不做任何操作
//    if (currentOrientation == orientation) { return; }
//    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
//    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
//
    UIInterfaceOrientation currentOrientation = _currentInterfaceOrientation;
     if (currentOrientation == orientation) { return; }
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    _currentInterfaceOrientation = orientation;
    
    // 获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:AnimationDuration];
    // 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
    // 给你的播放视频的view视图设置旋转
    self.playerView.transform = CGAffineTransformIdentity;
    self.playerView.transform = [self getTransformRotationAngle];
    // 开始旋转
    [UIView commitAnimations];
}

- (CGAffineTransform)getTransformRotationAngle {
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIInterfaceOrientation orientation = _currentInterfaceOrientation;
//    orientation = UIInterfaceOrientationLandscapeRight;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}


#pragma mark - setter

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    [self.btnFullScreen setTitle:isFullScreen?@"半屏":@"全屏" forState:UIControlStateNormal];
    [UIApplication sharedApplication].statusBarHidden = _isFullScreen;
}



#pragma mark - getter

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc]init];
        _playerView.backgroundColor = [UIColor redColor];
        
        if (@available(iOS 11.0, *)) {
            _playerView.frame = CGRectMake(0, self.view.safeAreaInsets.top, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) * 9 / 16.f);
        } else {
            _playerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds) * 9 / 16.f);
        }
        
    }
    return _playerView;
}

- (UIButton *)btnFullScreen {
    if (!_btnFullScreen) {
        _btnFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnFullScreen setTitle:@"全屏" forState:UIControlStateNormal];
        _btnFullScreen.backgroundColor = [UIColor orangeColor];
        [_btnFullScreen addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnFullScreen.frame = CGRectMake(CGRectGetWidth(self.playerView.frame)-50, CGRectGetHeight(self.playerView.frame)-50, 40, 30);
    }
    return _btnFullScreen;
}

- (UIButton *)btnClose {
    if (!_btnClose) {
        _btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnClose setTitle:@"关闭" forState:UIControlStateNormal];
        _btnClose.backgroundColor = [UIColor orangeColor];
        [_btnClose addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnClose.frame = CGRectMake(20, 20, 40, 30);
    }
    return _btnClose;
}


@end
