//
//  SearchResultCell.m
//  PlayMakr
//
//  Created by Oliver Andrews on 2015-06-21.
//  Copyright (c) 2015 Oliver Andrews. All rights reserved.
//

#import "SearchResultCell.h"

@implementation SearchResultCell

@synthesize mainTitle = _mainTitle;
@synthesize detail = _detail;
@synthesize showImage = _showImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
