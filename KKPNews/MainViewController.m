//
//  MainViewController.m
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/13/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import "MainViewController.h"
#import "YoutubeListCustomCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import <UIEMultiAccess/UIEMultiAccess.h>
#import <UIEMultiAccess/DNApplicationManager.h>
#import <UIEMultiAccess/DNAppCatalog.h>
#import <UIEMultiAccess/UMAApplicationInfo.h>

typedef NS_ENUM(NSInteger, SectionType) {
    SECTION_TYPE_SETTINGS,
    SECTION_TYPE_LAST_CONNECTED_DEVICE,
    SECTION_TYPE_CONNECTED_DEVICE,
    SECTION_TYPE_DISCOVERED_DEVICES,
};

typedef NS_ENUM(NSInteger, AlertType) {
    ALERT_TYPE_FAIL_TO_CONNECT,
    ALERT_TYPE_DISCOVERY_TIMEOUT,
};

static NSString *const kSettingsManualConnectionTitle = @"Manual Connection";
static NSString *const kSettingsManualConnectionSubTitle =
@"Be able to select a device which you want to connect.";
static NSString *const kDeviceNone = @"No Name";
static NSString *const kAddressNone = @"No Address";

static NSString *const kRowNum = @"rowNum";
static NSString *const kHeaderText = @"headerText";
static NSString *const kTitleText = @"HID Device Sample";

NSString *const kIsManualConnection = @"is_manual_connection";
static const NSTimeInterval kHidDeviceControlTimeout = 5;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MainViewController ()<UMAFocusManagerDelegate, UMAAppDiscoveryDelegate, UMAApplicationDelegate>

@property (nonatomic, strong) UMAFocusManager *focusManager;
@property (nonatomic, strong) NSArray *applications;
@property (nonatomic) BOOL remoteScreen;
@property (nonatomic) UMAApplication *umaApp;
@property (nonatomic) UMAHIDManager *hidManager;
@property (nonatomic) UMAInputDevice *connectedDevice;
@property (copy, nonatomic) void (^discoveryBlock)(UMAInputDevice *, NSError *);
@property (copy, nonatomic) void (^connectionBlock)(UMAInputDevice *, NSError *);
@property (copy, nonatomic) void (^disconnectionBlock)(UMAInputDevice *, NSError *);
@property (nonatomic) NSMutableArray *inputDevices;


@end

@implementation MainViewController
{
    BOOL receivedVideo;
    NSInteger item;
    BOOL isSeekForward;
    BOOL isSeekBackward;
    
    NSMutableArray *channelListJP;
    NSMutableArray *channelListEN;
    NSInteger count;
    NSString *videoIdString;
    NSInteger countDuration;
    BOOL refreshFact;
    BOOL spinnerFact;
    BOOL firstTime;
    
    NSInteger indexFocus;
    BOOL kkpTriggered;
    NSInteger directionFocus;
    
    BOOL internetActive;
    BOOL hostActive;
    BOOL loadApiFact;
    BOOL alertFact;
    BOOL videoEndedFact;
    
    BOOL moveDown;
    BOOL moveUp;
}

@synthesize youtube;

- (void)viewDidLoad {
    [super viewDidLoad];

    receivedVideo = NO;
    firstTime = YES;
    [self.navigationController setNavigationBarHidden:YES];
    self.playerView.delegate = self;
    item = 0;
    kkpTriggered = NO;
    directionFocus = 0;
    self.youtubeTableView.dataSource = self;
    self.youtubeTableView.delegate = self;
    self.youtubeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.videoPlaylist = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateText = [NSString stringWithFormat:@"%@: %@",[NSString stringWithFormat:NSLocalizedString(@"Last Updated", nil)],[dateFormatter stringFromDate:[NSDate date]]];
    self.dateTimeLabel.text = dateText;
    refreshFact = NO;
    spinnerFact = NO;
    self.loadingSpinner.hidden = YES;
    [self playlingYoutube];
    //customize progressbar
    UIImage *new = [UIImage imageNamed:@"thumbnail.png"];
    UIImage *myNewThumbnail = [MainViewController imageWithImage:new scaledToSize:CGSizeMake(20, 20)];
    [self.progressSlider setThumbImage:myNewThumbnail forState:UIControlStateNormal];
    UIImage *minImage = [[UIImage imageNamed:@"min"] stretchableImageWithLeftCapWidth:9 topCapHeight:0];
    UIImage *maxImage = [[UIImage imageNamed:@"max"] stretchableImageWithLeftCapWidth:9 topCapHeight:0];
    minImage = [MainViewController imageWithImage:minImage scaledToSize:CGSizeMake(4, 4)];
    maxImage = [MainViewController imageWithImage:maxImage scaledToSize:CGSizeMake(4, 4)];
    [self.progressSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [self.progressSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    internetActive = NO;
    hostActive = NO;
    loadApiFact = NO;
    alertFact = NO;
    videoEndedFact = NO;
    moveUp = NO;
    moveDown = NO;
    
#pragma setup UMA in ViewDidload
    _inputDevices = [NSMutableArray array];
    _umaApp = [UMAApplication sharedApplication];
    _umaApp.delegate = self;
    _hidManager = [_umaApp requestHIDManager];
    
    [_umaApp addViewController:self];
    
    //focus
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.youtubeTableView];
    //[_focusManager moveFocus:1];
    [_focusManager setHidden:YES];
    [_focusManager moveFocus:1 direction:1];
    
    [self prepareBlocks];
    //[_hidManager setDisconnectionCallback:_disconnectionBlock];
    

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [hidingView invalidate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UITapGestureRecognizer *tgpr_webView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(handleTapPressedOnWebView:)];
    tgpr_webView.delegate = self;
    [self.playerView addGestureRecognizer:tgpr_webView];
    
    [_hidManager setConnectionCallback:_connectionBlock];
    [_hidManager enableAutoConnectionWithDiscoveryTimeout:kHidDeviceControlTimeout
                                    WithDiscoveryInterval:kHidDeviceControlTimeout
                                    WithConnectionTimeout:kHidDeviceControlTimeout];
    [_hidManager startDiscoverWithDeviceName:nil];
    //-network
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    hostReachable = [Reachability reachabilityWithHostName:@"www.youtube.com"];
    [hostReachable startNotifier];
}

#pragma mark - network
- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable:
        {
            internetActive = NO;
            alertFact = YES;
            break;
            
        }
        case ReachableViaWiFi:
        {
            internetActive = YES;
            alertFact = YES;
            break;
            
        }
        case ReachableViaWWAN:
        {
            internetActive = YES;
            alertFact = YES;
            break;
        }
        default:
            break;
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            hostActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            hostActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            hostActive = YES;
            break;
        }
    }
    
    if (alertFact) {
        [self showingNetworkStatus];
    }
}

- (void)showingNetworkStatus
{
    NSLog(@"show network status %id",internetActive);
    alertFact = NO;
    if (internetActive) {
        if (videoEndedFact) {
            
            [self playerView:self.playerView didChangeToState:kYTPlayerStateEnded];
            videoEndedFact = NO;
        }
        
        if ([self.playerView playerState] == kYTPlayerStatePaused) {
            [self.playerView playVideo];
        }
        
        if (loadApiFact) {
            loadApiFact = NO;
            if (spinnerFact) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoId" object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoDuration" object:nil];
                [self callYoutube:self.regionJp];
            }
        }
        
        
    } else {

        alertFact = YES;
        loadApiFact = YES;
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Can Not Connected To The Internet.", nil)];
        
        alert = [UIAlertController alertControllerWithTitle:description
                                                    message:@""
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       alertFact = YES;
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)prepareBlocks
{
    __weak typeof(self) weakSelf = self;
    
    //
    // Block of Discovery Completion
    //
    _discoveryBlock = ^(UMAInputDevice *device, NSError *error) {
        UIAlertView *alertView;
        
        switch ([error code]) {
            case kUMADiscoveryDone: // Intentionally stops by the app
            case kUMADiscoveryFailed: // Discovery failed with some reason
                //[weakSelf.refreshControl endRefreshing];
                break;
            case kUMADiscoveryTimeout: // Timeout occurred
                [weakSelf.hidManager stopDiscoverDevice];
                alertView = [[UIAlertView alloc] initWithTitle:@"Discovery of HID Device finished"
                                                       message:@"If you would like to discover again, pull down the view."
                                                      delegate:weakSelf
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
                alertView.tag = ALERT_TYPE_DISCOVERY_TIMEOUT;
                [alertView show];
                //[weakSelf.refreshControl endRefreshing];
                break;
            case kUMADiscoveryDiscovered:       // Device discovered
                /* Get discovered devices and reload table*/
                [weakSelf.inputDevices addObject:device];
                //[weakSelf.sampleTableView reloadData];
                break;
            case kUMADiscoveryStarted:
                break;
            default:
                break;
        }
    };
    [_hidManager setDiscoveryCallback:_discoveryBlock];
    
    //
    // Block of Connection Complete
    //
    _connectionBlock = ^(UMAInputDevice *device, NSError *error) {
        UIAlertView *alertView;
        switch ([error code]) {
            case kUMAConnectedSuccess:
                [weakSelf.hidManager stopDiscoverDevice];
                weakSelf.connectedDevice = device;
                //[weakSelf.sampleTableView reloadData];
                break;
            case kUMAConnectedTimeout:
            case kUMAConnectedFailed:
                alertView =
                [[UIAlertView alloc] initWithTitle:@"Connection timeout occurred."
                                           message:@"Reset the last memory and start to discovery?"
                                          delegate:weakSelf
                                 cancelButtonTitle:@"No"
                                 otherButtonTitles:@"Yes", nil];
                alertView.tag = ALERT_TYPE_FAIL_TO_CONNECT;
                [alertView show];
                break;
            default:
                break;
                
        }
    };
    [_hidManager setConnectionCallback:_connectionBlock];
    
    //
    // Block of Disonnection Complete
    //
    _disconnectionBlock = ^(UMAInputDevice *device, NSError *error) {
        weakSelf.connectedDevice = nil;
        //[weakSelf.sampleTableView reloadData];
    };
    [_hidManager setDisconnectionCallback:_disconnectionBlock];
}

#pragma mark - oreintation
- (void)orientationChanged:(NSNotification *)notification
{
    if (spinnerFact) {
       // spinner.center = CGPointMake(self.youtubeTableView.center.x, 85.5);
    }
}

- (void)viewDidLayoutSubviews
{
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {

            if (self.youtubeTableView.hidden == true) {
                self.refreshButton.hidden = YES;
                if (self.controllerAreaView.hidden == NO) {
                    self.btmControlAreaConstraint.constant = 0;
                    self.heightControllerAreaConstraint.constant = 44;
                    self.heighDateAreaConstraint.constant = 0;
                } else {
                    self.btmControlAreaConstraint.constant = 0;
                    self.heightControllerAreaConstraint.constant = 0;
                    self.heighDateAreaConstraint.constant = 0;
                }
                
            } else {
                self.refreshButton.hidden = NO;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    self.btmControlAreaConstraint.constant = 400;
                    self.heightControllerAreaConstraint.constant = 44;
                    self.heighDateAreaConstraint.constant = 24;
                } else {
                    self.btmControlAreaConstraint.constant = 320;
                    self.heightControllerAreaConstraint.constant = 44;
                    self.heighDateAreaConstraint.constant = 24;
                }
                
            }

    } else {
        
            if (self.youtubeTableView.hidden == true) {
                self.refreshButton.hidden = YES;
                if (self.controllerAreaView.hidden == NO) {
                    self.playerViewTrailingConstraint.constant = 0;
                    self.heightControllerAreaConstraint.constant = 44;
                    self.heighDateAreaConstraint.constant = 0;
                } else {
                    self.playerViewTrailingConstraint.constant = 0;
                    self.heightControllerAreaConstraint.constant = 0;
                    self.heighDateAreaConstraint.constant = 0;
                }
                
            } else {
                self.refreshButton.hidden = NO;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    self.playerViewTrailingConstraint.constant = 400;
                    self.heightControllerAreaConstraint.constant = 44;
                     self.heighDateAreaConstraint.constant = 24;
                } else {
                    self.playerViewTrailingConstraint.constant = 320;
                    self.heightControllerAreaConstraint.constant = 44;
                    self.heighDateAreaConstraint.constant = 24;
                }
                
            }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handleTapPressedOnWebView:(UIGestureRecognizer *)gestureRecognizer
{
    [self hideWithFact:NO];
    [hidingView invalidate];
     hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

- (void)hideWithFact:(BOOL )fact
{
    if (fact) {
        self.btmControlAreaConstraint.constant = 0;
        self.heightControllerAreaConstraint.constant = 0;
        self.youtubeTableView.hidden = YES;
        self.controllerAreaView.hidden = YES;
        self.dateTimeLabel.hidden = YES;
    
    } else {

        self.btmControlAreaConstraint.constant = 320;
        self.heightControllerAreaConstraint.constant = 44;
        self.youtubeTableView.hidden = NO;
        self.controllerAreaView.hidden = NO;
        self.dateTimeLabel.hidden = NO;
    }
}

- (void)hide
{
     if ( self.youtubeTableView.hidden == YES && self.controllerAreaView.hidden == YES) {
         
          self.btmControlAreaConstraint.constant = 320;
          self.heightControllerAreaConstraint.constant = 44;
          self.youtubeTableView.hidden = NO;
          self.controllerAreaView.hidden = NO;
          self.dateTimeLabel.hidden = NO;
     } else {
         
          self.btmControlAreaConstraint.constant = 0;
          self.heightControllerAreaConstraint.constant = 0;
          self.youtubeTableView.hidden = YES;
          self.controllerAreaView.hidden = YES;
          self.dateTimeLabel.hidden = YES;
     }
}


- (void)playlingYoutube
{
    self.playerVars =  @{ @"playsinline" : @1,
                          @"controls" : @0,
                          @"showinfo" : @1,
                          @"modestbranding" : @0,
                          @"origin" :@"http://www.youtube.com"   };
    
    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
    [self copyArrYoutube];
}

- (void)copyArrYoutube
{
    [self.videoPlaylist removeAllObjects];
    self.videoPlaylist = [[NSMutableArray alloc] initWithCapacity:10];
    for (int i=0; i < [self.youtube.data count]; i++) {
        [self.videoPlaylist addObject:[[self.youtube.data objectAtIndex:i] objectForKey:@"videoId"]];
    }
}

#pragma mark - Call apis refresh
- (void)callYoutube:(BOOL )jp
{
    [hidingView invalidate];
    [self.youtube.durationList removeAllObjects];
    [self.youtube.data removeAllObjects];
    [self.youtubeTableView reloadData];
    self.youtube = [[Youtube alloc] init];
    
    refreshFact = YES;
    self.loadingSpinner.hidden = NO;
    spinnerFact = YES;
    
    if (jp) {
        channelListJP = [NSMutableArray arrayWithObjects:@"ANNnewsCH", @"tbsnewsi", @"NHKonline", @"JiJi", @"sankeinews", @"YomiuriShimbun", @"tvasahi", @"KyodoNews", @"asahicom", @"UCYfdidRxbB8Qhf0Nx7ioOYw", nil];
        count = [channelListJP count];
        countDuration = 1;
        for (int i = 0; i < [channelListJP count]; i++) {
            if ( i == [channelListJP count]-1 ) {
                [self.youtube getVideoPlaylistFromUploadIds:[channelListJP objectAtIndex:i] withNextPage:NO];
            } else {
                [self.youtube getChannelIdFromPlaylistName:[channelListJP objectAtIndex:i]];
            }
            
        }

    } else {
        channelListEN = [NSMutableArray arrayWithObjects:@"Euronews", @"bbcnews", @"AlJazeeraEnglish", @"AssociatedPress", @"RussiaToday", @"WashingtonPost", @"France24english", @"thenewyorktimes", @"CSPAN", @"NYPost", @"ReutersVideo", @"Bloomberg", @"Foxnewschannel", @"afpbbnews"  @"UCCcey5CP5GDZeom987gqTdg", nil];
        count = [channelListEN count];
        countDuration = 1;
        for (int i = 0; i < [channelListEN count]; i++) {
            if ( i == [channelListEN count]-1 ) {
                [self.youtube getVideoPlaylistFromUploadIds:[channelListEN objectAtIndex:i] withNextPage:NO];
            } else {
                [self.youtube getChannelIdFromPlaylistName:[channelListEN objectAtIndex:i]];
            }
            
        }

    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoId" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoDuration)
                                                 name:@"LoadVideoDuration" object:nil];
}

- (void)receivedLoadVideoId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        count--;
        if (count == 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            NSDate *dateFromString;
            for (NSDictionary* a in self.youtube.jsonRes) {
                NSArray *arr = a[@"items"];
                for (NSDictionary* q in arr) {
                    if (q[@"snippet"][@"thumbnails"][@"default"][@"url"] != nil) {
                        
                        dateFromString = [dateFormatter dateFromString:q[@"snippet"][@"publishedAt"]];
                        NSDictionary *data = @{ @"videoId":q[@"contentDetails"][@"videoId"],
                                                @"publishedAtList":dateFromString,
                                                @"thumbnail":q[@"snippet"][@"thumbnails"][@"default"][@"url"],
                                                @"title":q[@"snippet"][@"title"] };
                        
                        [self.youtube.data addObject:data];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoId" object:nil];
            //sort
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"publishedAtList" ascending:NO];
            [self.youtube.data sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
            
            NSString *reqVideoIds = @"";
            for (int i = 0; i < [self.youtube.data count]; i++) {
                reqVideoIds = [NSString stringWithFormat:@"%@,%@", reqVideoIds, [[self.youtube.data objectAtIndex:i] objectForKey:@"videoId"]];
            }
            
            if ([reqVideoIds characterAtIndex:0] == ',') {
                reqVideoIds = [reqVideoIds substringFromIndex:1];
            }
            
            videoIdString = reqVideoIds;
            [self callAllVideoDuration:videoIdString];
        }
    });
    
}

- (void)callAllVideoDuration:(NSString *)reqVideoIds
{
    int start = (int)[self.youtube.durationList count];
    NSInteger lengthCall = countDuration * 50;
    NSArray *arrString = [reqVideoIds componentsSeparatedByString:@","];
    
    if (lengthCall <= [arrString count]) {
        
        NSString *newArr = @"";
        for (int i = start; i < lengthCall; i++) {
            newArr = [NSString stringWithFormat:@"%@,%@", newArr, [arrString objectAtIndex:i]];
        }
        
        if ([newArr characterAtIndex:0] == ',') {
            newArr = [newArr substringFromIndex:1];
        }
        
        [self.youtube getVideoDurations:newArr];
    } else {
        [self receivedLoadVideoDuration];
    }
    
    
}

- (void)receivedLoadVideoDuration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        countDuration+=1;
        if (self.regionJp) {
            
            if (countDuration == [channelListJP count]) {
                item = 0;
                spinnerFact = NO;
                refreshFact = NO;
                self.loadingSpinner.hidden = YES;
                [spinner stopAnimating];
                if (self.playerView.playerState == kYTPlayerStateEnded) {
                    NSLog(@"state: playing %ld",(long)self.playerView.playerState);
                    [self.timerProgress invalidate];
                    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                } else if (self.playerView.playerState == kYTPlayerStatePlaying) {
                    refreshFact = YES;
                }
                [self copyArrYoutube];
                [self.youtubeTableView reloadData];
                hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoDuration" object:nil];
            } else {
                [self callAllVideoDuration:videoIdString];
            }
        } else {
            
            if (countDuration == [channelListEN count]) {
                item = 0;
                spinnerFact = NO;
                refreshFact = NO;
                self.loadingSpinner.hidden = YES;
                [spinner stopAnimating];
                if (self.playerView.playerState == kYTPlayerStateEnded) {
                    NSLog(@"state: playing %ld",(long)self.playerView.playerState);
                    [self.timerProgress invalidate];
                    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                    
                } else if (self.playerView.playerState == kYTPlayerStatePlaying) {
                    refreshFact = YES;
                }
                [self copyArrYoutube];
                [self.youtubeTableView reloadData];
                hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoDuration" object:nil];
            } else {
                [self callAllVideoDuration:videoIdString];
            }
        }
        
        
    });
}

#pragma mark - YTPlayerView delegate
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    videoEndedFact = NO;
    self.progressSlider.value = 0;
    self.currentTime.text = @"00:00";
    self.totalTime.text = @"00:00";
     [self.progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.playerView playVideo];
}


- (IBAction)sliderValueChanged:(UISlider *)sender
{
    [self hideWithFact:NO];
    [hidingView invalidate];
    hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
    
    NSInteger startTime = sender.value * self.playerTotalTime;
    [self.timerProgress invalidate];
    self.progressSlider.value = (double)startTime / self.playerTotalTime;
    
    double currentTimeChange = sender.value * self.playerTotalTime;
    NSTimeInterval currentTimeInterval = currentTimeChange;
    self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];
    [self.playerView seekToSeconds:currentTimeChange allowSeekAhead:YES];
     self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(makeProgressBarMoving:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timerProgress forMode:NSRunLoopCommonModes];
}

- (void)makeProgressBarMoving:(NSTimer *)timer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
        float total = [self.progressSlider value];
        double currentTime = [self.playerView currentTime];
        NSTimeInterval currentTimeInterval = currentTime;
        self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];
        
        if (isSeekForward) {
            if (total < 1) {
                float playerCurrentTime = [self.playerView currentTime];
                playerCurrentTime+=5;
                self.progressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
                [self.playerView seekToSeconds:playerCurrentTime allowSeekAhead:YES];
            } else {
                
                [self.timerProgress invalidate];
            }
            
        } else if (isSeekBackward){
            if (total < 1) {
                float playerCurrentTime = [self.playerView currentTime];
                playerCurrentTime-=5;
                self.progressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
                [self.playerView seekToSeconds:playerCurrentTime allowSeekAhead:YES];
                
            } else {
                
                [self.timerProgress invalidate];
            }
            
        } else {
            if (total < 1) {
                float playerCurrentTime = [self.playerView currentTime];
                self.progressSlider.value = (playerCurrentTime / (float)self.playerTotalTime);
                self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];
            } else {
                [self.timerProgress invalidate];
            }
            
        }
 
}

- (IBAction)refeshButtonPressed:(id)sender
{
    if (!spinnerFact) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        NSString *dateText = [NSString stringWithFormat:@"%@: %@",[NSString stringWithFormat:NSLocalizedString(@"Last Updated", nil)],[dateFormatter stringFromDate:[NSDate date]]];
        self.dateTimeLabel.text = dateText;
        loadApiFact = YES;
        [self callYoutube:self.regionJp];
    }

}

- (IBAction)buttonPressed:(id)sender
{
    UIImage *btnImagePause = [UIImage imageNamed:@"pause"];
    UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
    if (sender == self.playButton) {
        if ([[self.playButton imageForState:UIControlStateNormal] isEqual:btnImagePlay]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback Started" object:self];
            [self.playerView playVideo];
            [self.playButton setImage:btnImagePause forState:UIControlStateNormal];
        } else {
            [self.playerView pauseVideo];
            [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
        }
    }
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{

    if (state == kYTPlayerStateEnded) {
        videoEndedFact = YES;
        if (internetActive) {
            if(spinnerFact){
                NSLog(@"still loading");
            } else {
                if (refreshFact) {
                    item = 0;
                    refreshFact = NO;
                    NSLog(@"fact YES ended");
                    [_focusManager setFocusRootView:self.youtubeTableView];
                    [_focusManager moveFocus:1 direction:1];
                    [self.timerProgress invalidate];
                    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                    [self.youtubeTableView reloadData];
                } else {
                    
                    if (item == [self.youtube.data count]-1) {
                        item = 0;
                        [_focusManager setFocusRootView:self.youtubeTableView];
                        [_focusManager moveFocus:1 direction:1];
                        [self.timerProgress invalidate];
                        [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                        [self.youtubeTableView reloadData];
                        
                    } else {
                        if (moveDown) {
                            NSLog(@"continue move down");
                            item+=1;
                            [_focusManager moveFocus:1 direction:kUMAFocusForward];
                            [self.timerProgress invalidate];
                            [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                            [self.youtubeTableView reloadData];
                        }
                        
                        if (moveUp) {
                            NSLog(@"continue move up");
                            item-=1;
                            [_focusManager moveFocus:1 direction:kUMAFocusBackward];
                            [self.timerProgress invalidate];
                            [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                            [self.youtubeTableView reloadData];
                        }
                        
                    }
                }
                
            }
        } else {
            [self.timerProgress invalidate];
            [self.playerView pauseVideo];
        }

    } else if (state == kYTPlayerStatePlaying) {
        
        UIImage *btnImagePause = [UIImage imageNamed:@"pause"];
        [self.playButton setImage:btnImagePause forState:UIControlStateNormal];
        self.playerTotalTime = [self.playerView duration];
        self.totalTime.text = [self stringFromTimeInterval:self.playerTotalTime];
        double currentTime = [self.playerView currentTime];
        NSTimeInterval currentTimeInterval = currentTime;
        
        self.currentTime.text = [self stringFromTimeInterval:currentTimeInterval];

        [self.timerProgress invalidate];
        self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(makeProgressBarMoving:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timerProgress forMode:NSRunLoopCommonModes];
        if (firstTime) {
            [hidingView invalidate];
            hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
            firstTime = NO;
        }
        
        
    } else if (state == kYTPlayerStatePaused) {
        [self.timerProgress invalidate];
        UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
        [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
        
    } else if (state == kYTPlayerStateUnstarted) {
        if(spinnerFact){
            NSLog(@"still loading");
        } else {
            if (refreshFact) {
                item = 0;
                refreshFact = NO;
                NSLog(@"fact YES unstarted");
                [_focusManager setFocusRootView:self.youtubeTableView];
                [_focusManager moveFocus:1 direction:1];
                [self.timerProgress invalidate];
                [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                [self.youtubeTableView reloadData];
            } else {
                if (item == [self.youtube.data count]-1) {
                    item = 0;
                    [_focusManager setFocusRootView:self.youtubeTableView];
                    [_focusManager moveFocus:1 direction:1];
                    [self.timerProgress invalidate];
                    [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                    [self.youtubeTableView reloadData];
                    
                } else {
                    if (moveDown) {
                        NSLog(@"continue move down");
                        item+=1;
                        [_focusManager moveFocus:1 direction:kUMAFocusForward];
                        [self.timerProgress invalidate];
                        [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                        [self.youtubeTableView reloadData];
                    }
                    
                    if (moveUp) {
                        NSLog(@"continue move up");
                        item-=1;
                        [_focusManager moveFocus:1 direction:kUMAFocusBackward];
                        [self.timerProgress invalidate];
                        [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                        [self.youtubeTableView reloadData];
                    }

                }

            }
          
        }

    } else if (state == kYTPlayerStateBuffering){
        //NSLog(@"bufferring");
        //self.timerProgress = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(makeProgressBarMoving:) userInfo:nil repeats:YES];
    } else {
        NSLog(@"what state == %ld",(long)self.playerView.playerState);
    }
}

# pragma mark - table delegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (spinnerFact) {
        return 0;
    } else {
        if ([self.youtube.durationList count] != 0) {
            //return 50;
            return [self.youtube.durationList count];
        }else{
            return 0;
        }
    }
    
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"YoutubeListCustomCell";
    YoutubeListCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YoutubeListCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    if ([self.youtube.data count] != 0) {
        
        cell.name.text = [[self.youtube.data objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.tag = indexPath.row;
        NSString *duration = [self.youtube.durationList objectAtIndex:indexPath.row];
        cell.duration.text = [self durationText:duration];
        cell.thumnail.image = nil;
        
        if([[self.youtube.data objectAtIndex:indexPath.row] objectForKey:@"thumbnail"] != [NSNull null] ){
            [cell.thumnail sd_setImageWithURL:[NSURL URLWithString:[[self.youtube.data objectAtIndex:indexPath.row] objectForKey:@"thumbnail"]]
                                   placeholderImage:nil];
        }

    } else {
        cell.name.text = @"";
    }
    if (refreshFact) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        if (indexPath.row == item) {
            cell.contentView.backgroundColor = UIColorFromRGB(0xDADADA);
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 89;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.playerView pauseVideo];
    if (internetActive) {
        refreshFact = NO;
        item = indexPath.row;
        [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
        [self.youtubeTableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.youtubeTableView reloadData];
        
        NSInteger indexF = [_focusManager focusIndex];
        if (indexF > item) {
            [_focusManager moveFocus:indexF-item direction:kUMAFocusBackward];
        } else if (indexF < item) {
            [_focusManager moveFocus:item-indexF direction:kUMAFocusForward];
        }

    } else {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"The internet is not available.", nil)];
        
        alert = [UIAlertController alertControllerWithTitle:description
                                                    message:@""
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                    
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        [self.youtubeTableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.youtubeTableView reloadData];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    kkpTriggered = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
    [hidingView invalidate];

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [hidingView invalidate];
    
    if (kkpTriggered) {
        [hidingView invalidate];
    } else {
        hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
    }
    
}


- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    if (hours > 0) {
        
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
}

- (NSString *)durationText:(NSString *)duration
{
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];
    
    while ([duration length] > 1) { //only one letter remains after parsing
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];
        
        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];
        
        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];
        
        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];
        
        if ([[duration substringToIndex:1] isEqualToString:@"H"]) {
            hours = [durationPart intValue];
            
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"]) {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"]) {
            seconds = [durationPart intValue];
        }
    }
    if (hours != 0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
}


float level = 0.0;
- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{
    kkpTriggered = YES;
    //[hidingView invalidate];
//    NSLog(@"distance %lu direction %ld",(unsigned long)distance,(long)direction);
//    NSLog(@"focus index %ld",(long)[_focusManager focusIndex]);
    
    
    [hidingView invalidate];
    if (self.controllerAreaView.hidden == YES) {
        self.controllerAreaView.hidden = NO;
        hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
    } else {
        if ((long)direction == 1) {
            level += 0.05;
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:level];
            hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];

        } else {
            level -= 0.05;
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:level];
            hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];

        }
    }
    return YES;
}

- (BOOL)umaDidTranslateWithDistance:(NSInteger)distanceX distanceY:(NSInteger)distanceY
{
    if (!internetActive) {
        [self.playerView pauseVideo];
        return YES;
    } else {
        kkpTriggered = YES;
        [hidingView invalidate];
//        NSLog(@"distanceX %lu distanceY %ld",(unsigned long)distanceX,(long)distanceY);
//        NSLog(@"focus index %ld",(long)[_focusManager focusIndex]);
        indexFocus = [_focusManager focusIndex];
        if (spinnerFact) {
            
            if ((distanceX == 1 && distanceY == 0) || (distanceX == 0 && distanceY == 1) ) {
                moveDown = YES;
                moveUp = NO;
                if (item == [self.videoPlaylist count]-1) {
                    item = 0;
                    [self.timerProgress invalidate];
                    UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
                    [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
                    [self.playerView loadWithVideoId:[self.videoPlaylist objectAtIndex:item] playerVars:self.playerVars];
                    [self.youtubeTableView reloadData];
                } else {
                    
                    item+=1;
                    [self.timerProgress invalidate];
                    UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
                    [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
                    [self.playerView loadWithVideoId:[self.videoPlaylist objectAtIndex:item] playerVars:self.playerVars];
                    [self.youtubeTableView reloadData];
                }
                
                
            } else if ((distanceX == -1 && distanceY == 0) || (distanceX == 0 && distanceY == -1)) {
                moveUp = YES;
                moveDown = NO;
                if (item == 0) {
                    item = [self.videoPlaylist count]-1;
                    [self.timerProgress invalidate];
                    UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
                    [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
                    [self.playerView loadWithVideoId:[self.videoPlaylist objectAtIndex:item] playerVars:self.playerVars];
                    [self.youtubeTableView reloadData];
                } else {
                    item-=1;
                    [self.timerProgress invalidate];
                    UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
                    [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
                    [self.playerView loadWithVideoId:[self.videoPlaylist objectAtIndex:item] playerVars:self.playerVars];
                    [self.youtubeTableView reloadData];
                    
                }
            }
            return YES;
            
        } else {
            if (refreshFact) {
                item = 0;
                [_focusManager setFocusRootView:self.youtubeTableView];
                [_focusManager moveFocus:1 direction:1];
                
                [self.timerProgress invalidate];
                UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
                [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
                [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                [self.youtubeTableView reloadData];
                refreshFact = NO;
                return YES;
                
            } else {
                if (self.controllerAreaView.hidden == YES) {
                    self.controllerAreaView.hidden = NO;
                } else {
                    if ((distanceX == 1 && distanceY == 0) || (distanceX == 0 && distanceY == 1) ) {
                        moveDown = YES;
                        moveUp = NO;
                        if (item == [self.youtube.data count]-1) {
                            item = 0;
                            [self.timerProgress invalidate];
                            UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
                            [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
                            [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                            [self.youtubeTableView reloadData];
                        } else {
                            
                            item+=1;
                            [self.timerProgress invalidate];
                            UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
                            [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
                            [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                            [self.youtubeTableView reloadData];
                        }
                        
                        
                    } else if ((distanceX == -1 && distanceY == 0) || (distanceX == 0 && distanceY == -1)) {
                        moveUp = YES;
                        moveDown = NO;
                        if (item == 0) {
                            item = [self.youtube.data count]-1;
                            [self.timerProgress invalidate];
                            UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
                            [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
                            [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                            [self.youtubeTableView reloadData];
                        } else {
                            item-=1;
                            [self.timerProgress invalidate];
                            UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
                            [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
                            [self.playerView loadWithVideoId:[[self.youtube.data objectAtIndex:item] objectForKey:@"videoId"] playerVars:self.playerVars];
                            [self.youtubeTableView reloadData];
                            
                        }
                    }
                    if (distanceX == 0 && distanceY == 1) {
                        directionFocus = 0;
                        indexFocus+=2;
                        [_focusManager moveFocus:1 direction:kUMAFocusForward];
                    } else if (distanceX == 0 && distanceY == -1) {
                        directionFocus = 1;
                        [_focusManager moveFocus:1 direction:kUMAFocusBackward];
                    }
                }
                hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
                return NO;
                
            }
            
        }

    }
   
}


- (NSString *)getButtonName:(UMAInputButtonType)button
{
    switch (button) {
        case kUMAInputButtonTypeBack:
            return @"Back";
        case kUMAInputButtonTypeDown:
            return @"Down";
        case kUMAInputButtonTypeHome:
            return @"Home";
        case kUMAInputButtonTypeLeft:
            return @"Left";
        case kUMAInputButtonTypeMain:
            return @"Main";
        case kUMAInputButtonTypeRight:
            return @"Right";
        case kUMAInputButtonTypeUp:
            return @"UP";
        case kUMAInputButtonTypeVR:
            return @"VR";
        default:
            return @"Unknown";
    }
}

#pragma mark - UMARemoteInputEventDelegate

- (BOOL)umaDidPressDownButton:(UMAInputButtonType)button
{
    
    return YES;
}


- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button
{
    if ([[self getButtonName:button] isEqualToString:@"Main"]) {
        UIImage *btnImagePause = [UIImage imageNamed:@"pause"];
        UIImage *btnImagePlay = [UIImage imageNamed:@"play"];
        if (self.controllerAreaView.hidden == YES) {
            self.controllerAreaView.hidden = NO;
        } else {
            if ([[self.playButton imageForState:UIControlStateNormal] isEqual:btnImagePlay]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Playback Started" object:self];
                [self.playerView playVideo];
                [self.playButton setImage:btnImagePause forState:UIControlStateNormal];
            } else {
                [self.playerView pauseVideo];
                [self.playButton setImage:btnImagePlay forState:UIControlStateNormal];
            }
        }
        [hidingView invalidate];
        hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
        return YES;
    }
    
    if ([[self getButtonName:button] isEqualToString:@"VR"]) {
        if (self.controllerAreaView.hidden == YES && self.youtubeTableView.hidden == YES) {
            self.controllerAreaView.hidden = NO;
            [hidingView invalidate];
            hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
        }
        
        if (self.controllerAreaView.hidden == NO && self.youtubeTableView.hidden == NO) {
            [hidingView invalidate];
            [self callYoutube:self.regionJp];
        }
        
    }
    
    if ([[self getButtonName:button] isEqualToString:@"Back"]) {
        
        [hidingView invalidate];
        if (self.controllerAreaView.hidden == NO && self.youtubeTableView.hidden == YES) {
            self.controllerAreaView.hidden = YES;
            
        } else if (self.controllerAreaView.hidden == YES && self.youtubeTableView.hidden == YES) {
            [self hideWithFact:NO];
            hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
            
        } else {
            [self hideWithFact:YES];

        }
    }
    
    return YES;
}

- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button
{
    return YES;
}

- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button state:(UMAInputGestureRecognizerState)state
{
    [hidingView invalidate];
    if (self.controllerAreaView.hidden == YES) {
        self.controllerAreaView.hidden = NO;
        hidingView = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
    } else {
        if ([[self getButtonName:button] isEqualToString:@"Right"]) {
            if (state == 0) {
                isSeekForward = true;
            } else {
                isSeekForward = false;
            }
        } else if ([[self getButtonName:button] isEqualToString:@"Left"]){
            if (state == 0) {
                isSeekBackward = true;
            } else {
                isSeekBackward = false;
            }
        }
    }
   

    return YES;
}

- (BOOL)umaDidDoubleClickButton:(UMAInputButtonType)button
{
    return YES;
}

- (void)umaDidAccelerometerUpdate:(UMAAcceleration)acceleration
{
    
}




#pragma mark - UMAAppDiscoveryDelegate
- (void)didDiscoverySucceed:(NSArray *)appInfo
{
    
}
#pragma mark - UMAApplicationDelegate

- (UIViewController *)uma:(UMAApplication *)application requestRootViewController:(UIScreen *)screen {
    // This sample does not use this delegate
    return nil;
}

- (void)didDiscoveryFail:(int)reason withMessage:(NSString *)message;
{
    
}
- (void)uma:(UMAApplication *)application didConnectInputDevice:(UMAInputDevice *)device
{
    
}

- (void)uma:(UMAApplication *)application didDisconnectInputDevice:(UMAInputDevice *)device
{
    
}


@end
