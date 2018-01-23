//
//  PLTextField.m
//  PhotoLibrary
//
//  Created by ylz on 16/8/15.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "PLTextField.h"

@implementation PLTextField

- (instancetype)initWithPlaceholder:(NSString *)placeholder leftImage:(NSString *)leftImage{
    self = [super init];
    if (self) {
        self.textColor = [UIColor whiteColor];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"输入%@",placeholder]
                                                                     attributes:@{NSForegroundColorAttributeName:[UIColor lightTextColor]}];
        self.keyboardType = UIKeyboardTypeASCIICapable;
        self.clearButtonMode = UITextFieldViewModeAlways;
        self.tintColor = [UIColor whiteColor];
        self.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:leftImage]];
        self.leftViewMode = UITextFieldViewModeAlways;

    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect textRect = [super textRectForBounds:bounds];
    return CGRectOffset(textRect, 20, 0);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
