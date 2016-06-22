//
//  Youtube.h
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/13/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Youtube : NSObject
{
    NSMutableData* receivedData;
}

@property (nonatomic, copy) NSString *siteURLString;
@property (nonatomic, copy) NSString *search;
@property (nonatomic, copy) NSString *searchTerm;
@property (nonatomic, copy) NSString *video;
@property (nonatomic, copy) NSString *youtube_api_key;
@property (nonatomic, copy) NSString *part;
@property (nonatomic, copy) NSString *nextPageToken;
@property (nonatomic, copy) NSString *prevPageToken;
@property (nonatomic, copy) NSString *regionCode;
@property (nonatomic, copy) NSString *hl;
@property (nonatomic, copy) NSString *videoIdListForGetDuration;


@property (nonatomic, retain) NSMutableArray *durationList;
@property (nonatomic, retain) NSMutableArray *selectedType;
@property (nonatomic, retain) NSMutableArray *data;

@property (nonatomic, retain) NSDictionary *searchResults;

@property (nonatomic, retain) NSDictionary *channelsResults;


- (id)init;
- (void)changeIndexNextPage:(int )newIndexNextPage;
- (void)getChannelIdFromPlaylistName:(NSString *)playlistName;
- (void)getVideoPlaylistFromUploadIds:(NSString *)uploadsId withNextPage:(BOOL)nextPage;
- (void)getVideoDurations:(NSString *)videoId;

@end
