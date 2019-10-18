//
//  UIKatexView.m
//  ExampleApp-iOS
//
//  Created by Ian Arawjo on 10/12/14.
//  Copyright (c) 2014 Ian Arawjo. All rights reserved.
//

@import WebKit;
#import "UIKatexView.h"
#define DEFAULT_DELIMITER @"$"
#define DEFAULT_FRAMEWIDTH 200

@implementation UIKatexView {
    NSLayoutConstraint * _heightConstraint;
    NSLayoutConstraint * _widthConstraint;
    WKWebView * _katexWebView;
    CGPoint _storedCenter;
    
    NSString * _delimiter;
    float _framewidth;
}

// * Use this instead of initWithFrame! *
//+(instancetype)katexView:(NSString*)tex center:(CGPoint)center {
//    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
//    return [self katexView:tex center:center delimiter:DEFAULT_DELIMITER webView:webView  framewidth:DEFAULT_FRAMEWIDTH];
//}
//+(instancetype)katexView:(NSString*)tex center:(CGPoint)center delimiter:(NSString *)delim {
//    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
//    return [self katexView:tex center:center delimiter:DEFAULT_DELIMITER webView:webView framewidth:DEFAULT_FRAMEWIDTH];
//}

+(instancetype)katexView:(NSString*)tex center:(CGPoint)center delimiter:(NSString *)delim webView: (WKWebView*)webView {
    return [self katexView:tex center:center delimiter:delim webView:webView framewidth:DEFAULT_FRAMEWIDTH];
}
+(instancetype)katexView:(NSString*)tex center:(CGPoint)center delimiter:(NSString*)delim webView: (WKWebView*)webView framewidth:(float)width {
    UIKatexView * k = [[UIKatexView alloc] initWithFrame:CGRectZero];
    [k setCenter:center];
    [k setDelimiter:delim];
    [k setFrameWidth:width];
    [k setWebView:webView];
    [k loadKatex:tex];
    return k;
}
-(void)setDelimiter:(NSString*)delim {
    _delimiter = delim;
}
-(void)setFrameWidth:(float)w {
    _framewidth = w;
}
-(void)setCenter:(CGPoint)center {
    [super setCenter:center];
    _storedCenter = center;
}

-(void)setWebView:(WKWebView*)webView {
    _katexWebView = webView;
}

-(void)loadKatex:(NSString*)content {
    if (!content) return;
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"katex/index" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

    // Here's where the magic happens...
    // Ideally we want: I heard that $c = \sqrt{a^2 - b^2}$ but I don't believe it.
    // But we can only do that from a file.
    // In-line, we escape:
    //NSString* content = @"I heard that $c = \\sqrt{a^2 - b^2}$ but I don't believe it.";
    if([content rangeOfString:_delimiter].location != NSNotFound) { // Expression inside text.
        NSRange r;
        BOOL intex = NO;
        while ((r = [content rangeOfString:_delimiter]).location != NSNotFound) {
            content = [content stringByReplacingCharactersInRange:r
                                                       withString:(intex ? @"</span>" : @"<span class=\"tex\">")];
            intex = !intex;
        }
        if (intex) NSLog(@"Katex iOS: Error: No closing $.");
    } else { // Raw KaTeX.
        content = [NSString stringWithFormat:@"<span class=\"tex\">%@</span>", content];
    }
    
    // Place into HTML
    appHtml = [appHtml stringByReplacingOccurrencesOfString:@"$LATEX$"
                                                 withString:content];
    
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    
    // Add katex web view (needed for formatting)
    [self addSubview:_katexWebView];
    
    [_katexWebView loadHTMLString:appHtml baseURL:baseURL];
    [_katexWebView setUserInteractionEnabled:NO];
//    _katexWebView = webView;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
