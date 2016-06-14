//
//  youtubeListCustomCell.h
//  KKPNews
//
//  Created by Siam System Deverlopment on 6/13/2559 BE.
//  Copyright © 2559 Siam System Deverlopment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YoutubeListCustomCell : UITableViewCell

@property(weak,nonatomic) IBOutlet UILabel *name;
@property(weak,nonatomic) IBOutlet UIImageView *thumnail;
@property (weak, nonatomic) IBOutlet UILabel *duration;

@end
