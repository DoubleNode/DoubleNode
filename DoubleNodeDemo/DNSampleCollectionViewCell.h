//
//  DNSampleCollectionViewCell.h
//  DoubleNodeDemo
//
//  Created by Darren Ehlers on 1/14/15.
//  Copyright (c) 2015 DoubleNode. All rights reserved.
//

#import "DNCollectionViewCell.h"

@interface DNSampleCollectionViewCell : DNCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel*   nameLabel;
@property (weak, nonatomic) IBOutlet UILabel*   timestampLabel;

@end
