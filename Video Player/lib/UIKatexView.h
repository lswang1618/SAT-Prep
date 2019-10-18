//
//  UIKatexView.h
//  ExampleApp-iOS
//
//  Created by Ian Arawjo on 10/12/14.
//  Copyright (c) 2014 Ian Arawjo. All rights reserved.
//

@import WebKit;
#import <UIKit/UIKit.h>

@interface UIKatexView : UIView <UIWebViewDelegate>

/** Create a KaTeX view at the given center point.
 // * Since web views load asynchonously, 'center' ensures that you
 // * can set the frame at initialization. */
//+(instancetype)katexView:(NSString*)tex center:(CGPoint)center;

/** Constructors for custom settings. Default delimiter = $, width = 200. */
+(instancetype)katexView:(NSString*)tex center:(CGPoint)center delimiter:(NSString*)delim webView: (WKWebView*)webView;
//+(instancetype)katexView:(NSString*)tex center:(CGPoint)center delimiter:(NSString*)delim;
//+(instancetype)katexView:(NSString*)tex center:(CGPoint)center delimiter:(NSString*)delim framewidth:(float)width;
//+(instancetype)katexView:(NSString*)tex center:(CGPoint)center framewidth:(float)width;

@property (nonatomic, readwrite) WKWebView* katexWebView;
@property (nonatomic, readwrite) NSLayoutConstraint* heightConstraint;
@property (nonatomic, readwrite) NSLayoutConstraint* widthConstraint;

@end

