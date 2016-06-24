//
//  FirstScreenViewController.m
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/15/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import "FirstScreenViewController.h"
#import "MainViewController.h"

@interface FirstScreenViewController ()

@end

@implementation FirstScreenViewController
{
    NSInteger count;
    NSInteger countDuration;
    NSInteger item;
    NSMutableArray *channelListJP;
    NSMutableArray *channelListEN;
    NSString *videoIdString;
    BOOL jp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    jp = YES;
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *region = [currentLocale objectForKey:NSLocaleCountryCode];
    NSLog(@"region code %@",region);
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"tutorialPass"];
    if ([region isEqualToString:@"JP"]) {
        jp = YES;
    } else {
        jp = NO;
    }
    
    if (jp) {
        channelListJP = [NSMutableArray arrayWithObjects:@"ANNnewsCH", @"tbsnewsi", @"NHKonline", @"JiJi", @"sankeinews", @"YomiuriShimbun", @"tvasahi", @"KyodoNews", @"asahicom", @"UCYfdidRxbB8Qhf0Nx7ioOYw", nil];
        count = [channelListJP count];
    } else {
        channelListEN = [NSMutableArray arrayWithObjects:@"Euronews", @"bbcnews", @"AlJazeeraEnglish", @"AssociatedPress", @"RussiaToday", @"WashingtonPost", @"France24english", @"thenewyorktimes", @"CSPAN", @"NYPost", @"ReutersVideo", @"Bloomberg", @"Foxnewschannel", @"afpbbnews"  @"UCCcey5CP5GDZeom987gqTdg", nil];
        count = [channelListEN count];
    }
    
    countDuration = 1;
    item = 0;
    videoIdString = @"";

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"tutorialPass"]) {
        
        self.youtube = [[Youtube alloc] init];
        [self callYoutube];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedLoadVideoId)
                                                     name:@"LoadVideoId" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedLoadVideoDuration)
                                                     name:@"LoadVideoDuration" object:nil];
        
    } else {
        [self performSegueWithIdentifier:@"TutorialPhase" sender:@0];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (void)callYoutube
{
    if (jp) {
        for (int i = 0; i < [channelListJP count]; i++) {
            if ( i == [channelListJP count]-1 ) {
                [self.youtube getVideoPlaylistFromUploadIds:[channelListJP objectAtIndex:i] withNextPage:NO];
            } else {
                [self.youtube getChannelIdFromPlaylistName:[channelListJP objectAtIndex:i]];
            }
            
        }
//        if ( item == [channelListJP count]-1 ) {
//            [self.youtube getVideoPlaylistFromUploadIds:[channelListJP objectAtIndex:item] withNextPage:NO];
//        } else {
//            [self.youtube getChannelIdFromPlaylistName:[channelListJP objectAtIndex:item]];
//        }
    } else {
        
        for (int i = 0; i < [channelListEN count]; i++) {
            if ( i == [channelListEN count]-1 ) {
                [self.youtube getVideoPlaylistFromUploadIds:[channelListEN objectAtIndex:i] withNextPage:NO];
            } else {
                [self.youtube getChannelIdFromPlaylistName:[channelListEN objectAtIndex:i]];
            }
            
        }
        
    }

    //[self.youtube getChannelIdFromPlaylistName:[channelList objectAtIndex:item]];
}

- (void)receivedLoadVideoId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        count--;
        item++;
        if (count == 0) {
            NSLog(@"what we got --- ");
            //NSLog(@"%@",self.youtube.jsonRes);
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
//                NSLog(@"videoID: %@ publishedAt: %@", [[self.youtube.data objectAtIndex:i] objectForKey:@"videoId"], [[self.youtube.data objectAtIndex:i] objectForKey:@"publishedAtList"]);
                reqVideoIds = [NSString stringWithFormat:@"%@,%@", reqVideoIds, [[self.youtube.data objectAtIndex:i] objectForKey:@"videoId"]];
            }
            
            if ([reqVideoIds characterAtIndex:0] == ',') {
                reqVideoIds = [reqVideoIds substringFromIndex:1];
            }
            videoIdString = reqVideoIds;
            [self callAllVideoDuration:videoIdString];
        } else {
            //[self callYoutube];
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
        NSLog(@"count %ld",(long)countDuration);
        if (jp) {
            
            if (countDuration == [channelListJP count]) {
                [self performSegueWithIdentifier:@"mainSegue" sender:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoDuration" object:nil];
            } else {
                [self callAllVideoDuration:videoIdString];
            }
        } else {
            
            if (countDuration == [channelListEN count]) {
                [self performSegueWithIdentifier:@"mainSegue" sender:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoDuration" object:nil];
            } else {
                [self callAllVideoDuration:videoIdString];
            }
        }

    });
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"mainSegue"]){
        
        MainViewController *dest = segue.destinationViewController;
        dest.youtube = self.youtube;
        dest.regionJp = jp;
    }
}


@end
