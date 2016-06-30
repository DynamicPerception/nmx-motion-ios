//
//  JSMotorRampingTableViewCell.h
//  Joystick
//
//  Created by Mitch Middler on 6/24/16.
//  Copyright © 2016 Dynamic Perception. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSMotorRampingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *frameCount1;
@property (weak, nonatomic) IBOutlet UILabel *frameCount2;
@property (weak, nonatomic) IBOutlet UILabel *frameCount3;

@property (nonatomic, strong)	IBOutlet	UISlider *	slideIncreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	slideIncreaseFinal;
@property (nonatomic, strong)	IBOutlet	UISlider *	slideDecreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	slideDecreaseFinal;

@property (nonatomic, strong)	IBOutlet	UISlider *	panIncreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	panIncreaseFinal;
@property (nonatomic, strong)	IBOutlet	UISlider *	panDecreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	panDecreaseFinal;

@property (nonatomic, strong)	IBOutlet	UISlider *	tiltIncreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	tiltIncreaseFinal;
@property (nonatomic, strong)	IBOutlet	UISlider *	tiltDecreaseStart;
@property (nonatomic, strong)	IBOutlet	UISlider *	tiltDecreaseFinal;

@property (weak, nonatomic) IBOutlet UILabel *slideLbl1;
@property (weak, nonatomic) IBOutlet UILabel *slideLbl2;
@property (weak, nonatomic) IBOutlet UILabel *slideLbl3;
@property (weak, nonatomic) IBOutlet UILabel *slideLbl4;

@property (weak, nonatomic) IBOutlet UILabel *panLbl1;
@property (weak, nonatomic) IBOutlet UILabel *panLbl2;
@property (weak, nonatomic) IBOutlet UILabel *panLbl3;
@property (weak, nonatomic) IBOutlet UILabel *panLbl4;

@property (weak, nonatomic) IBOutlet UILabel *tiltLbl1;
@property (weak, nonatomic) IBOutlet UILabel *tiltLbl2;
@property (weak, nonatomic) IBOutlet UILabel *tiltLbl3;
@property (weak, nonatomic) IBOutlet UILabel *tiltLbl4;

@end
