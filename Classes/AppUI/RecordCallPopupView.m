//
//  RecordCallPopupView.m
//  linphone
//
//  Created by Apple on 5/17/17.
//
//

#import "RecordCallPopupView.h"

@interface RecordCallPopupView (){
    NSTimer *firedTime;
    int durationTime;
}

@end

@implementation RecordCallPopupView
@synthesize _timeSlider, _btnPlay, _lbTime, _lbTotal, _lbBackground, _tapGesture, _recordFile;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:(224/255.0) green:(255/255.0)
                                                blue:(128/255.0) alpha:1.0];
        self.layer.cornerRadius = 4.0;
        
        //  button play
        _btnPlay = [UIButton buttonWithType: UIButtonTypeCustom];
        _btnPlay.frame = CGRectMake(7, 7, frame.size.height-14, frame.size.height-14);
        [_btnPlay setBackgroundImage:[UIImage imageNamed:@"play_file_transfer.png"]
                            forState:UIControlStateNormal];
        [_btnPlay addTarget:self
                     action:@selector(btnPlayPressed:)
           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _btnPlay];
        
        _lbBackground = [[UILabel alloc] initWithFrame: CGRectMake(2*_btnPlay.frame.origin.x+_btnPlay.frame.size.width, _btnPlay.frame.origin.y, frame.size.width-3*_btnPlay.frame.origin.x-_btnPlay.frame.size.width, _btnPlay.frame.size.height)];
        _lbBackground.backgroundColor = UIColor.whiteColor;
        [self addSubview: _lbBackground];
        
        _timeSlider = [[UISlider alloc] initWithFrame: CGRectMake(_lbBackground.frame.origin.x+10, _btnPlay.frame.origin.y+_btnPlay.frame.size.height/2, _lbBackground.frame.size.width-20, _btnPlay.frame.size.height/2)];
        [_timeSlider setThumbImage:[UIImage imageNamed:@"lk_slider.png"]
                          forState:UIControlStateNormal];
        [_timeSlider setMinimumTrackImage:[UIImage imageNamed:@"left_slider"]
                                 forState:UIControlStateNormal];
        [_timeSlider setMaximumTrackImage:[UIImage imageNamed:@"right_slider"]
                                 forState: UIControlStateNormal];
        _timeSlider.value = 0;
        [self addSubview: _timeSlider];
        
        _lbTime = [[UILabel alloc] initWithFrame: CGRectMake(_timeSlider.frame.origin.x, _btnPlay.frame.origin.y, _timeSlider.frame.size.width/2, _btnPlay.frame.size.height/2)];
        _lbTime.font = [UIFont fontWithName:HelveticaNeue size:13.0];
        _lbTime.backgroundColor = UIColor.clearColor;
        _lbTime.textAlignment = NSTextAlignmentLeft;
        _lbTime.text = @"0:0";
        [self addSubview: _lbTime];
        
        _lbTotal = [[UILabel alloc] initWithFrame: CGRectMake(_lbTime.frame.origin.x+_lbTime.frame.size.width, _lbTime.frame.origin.y, _lbTime.frame.size.width, _lbTime.frame.size.height)];
        _lbTotal.font = [UIFont fontWithName:HelveticaNeue size:13.0];
        _lbTotal.backgroundColor = UIColor.clearColor;
        _lbTotal.textAlignment = NSTextAlignmentRight;
        [self addSubview: _lbTotal];
    }
    return self;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //  Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [viewBackground addGestureRecognizer:_tapGesture];
    [aView addSubview:viewBackground];
    
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

- (void)closePopupViewWhenTagOut{
    if (_player.isPlaying) {
        [_player stop];
        [firedTime invalidate];
    }
    
    [self fadeOut];
    [self.superview removeGestureRecognizer:_tapGesture];
}

- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut {
    _player = nil;
    
    //xoa background black
    for (UIView *subView in self.window.subviews){
        if (subView.tag == 20){
            [subView removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:.35 animations:^{
        [self setAlpha: 0.0];
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3)];
    }completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)showTotalLengthOfRecordFile {
    NSURL *recordURL = [self getUrlOfRecordFile: _recordFile];
    
    // Lấy độ dài của record file
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:recordURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    durationTime = ceil(CMTimeGetSeconds(audioDuration));
    NSString *total = [self timeFormatted: durationTime];
    _lbTotal.text = total;
    _lbTime.text = @"00:00";
    
    _timeSlider.maximumValue = durationTime;
    _timeSlider.minimumValue = 0;
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours == 0) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }
}

- (void)btnPlayPressed: (UIButton *)sender {
    NSURL *recordURL = [self getUrlOfRecordFile: _recordFile];
    NSData *audioData = [NSData dataWithContentsOfURL:recordURL];
    
    NSError *error;
    if (_player == nil) {
        _player = [[AVAudioPlayer alloc] initWithData:audioData fileTypeHint:AVFileTypeAMR error:&error];
        _player.delegate = self;
    }
    
    if (_player.isPlaying) {
        [_player pause];
        [firedTime invalidate];
        [_btnPlay setBackgroundImage:[UIImage imageNamed:@"play_file_transfer.png"]
                            forState:UIControlStateNormal];
    }else{
        [_player prepareToPlay];
        [_player play];
        
        firedTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                   selector:@selector(timerFired:)
                                                   userInfo:nil repeats:YES];
        
        [_player playAtTime: _player.currentTime];
        [_btnPlay setBackgroundImage:[UIImage imageNamed:@"pause_file_transfer.png"]
                            forState:UIControlStateNormal];
    }
}

// Hàm trả về đường dẫn đến file record
- (NSURL *)getUrlOfRecordFile: (NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Kiểm tra folder có tồn tại hay không?
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", folder_call_records, fileName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: path];
    if (!fileExists) {
        return nil;
    }else{
        return [[NSURL alloc] initFileURLWithPath: path];
    }
}

// Cập nhật thời gian chạy của record
- (void)timerFired: (NSTimer*)curTimer {
    [curTimer timeInterval];
    int currentTime = (int)ceil(_player.currentTime);
    NSString *time = [self timeFormatted: currentTime];
    _lbTime.text = time;
    _timeSlider.value = currentTime;
}



// Khi play hết audio message
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_btnPlay setBackgroundImage:[UIImage imageNamed:@"play_file_transfer.png"]
                        forState:UIControlStateNormal];
    _lbTime.text = @"00:00";
    [firedTime invalidate];
    _timeSlider.value = 0;
}

@end
