//
//  SearchResultCell.h
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-21.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface SearchResultCell : PFTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *mainTitle;
@property (nonatomic, weak) IBOutlet UILabel *detail;
@property (nonatomic, weak) IBOutlet PFImageView *showImage;

@end
