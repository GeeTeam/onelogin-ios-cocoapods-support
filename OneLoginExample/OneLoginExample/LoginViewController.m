//
//  LoginViewController.m
//  OneLoginExample
//
//  Created by noctis on 2019/8/8.
//  Copyright © 2019 geetest. All rights reserved.
//

#import "LoginViewController.h"
#import <OneLoginSDK/OneLoginSDK.h>

//#define NeedCustomAuthUI

@interface LoginViewController () <OneLoginDelegate>

@property (weak, nonatomic) IBOutlet UIButton *normalLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *popupLoginButton;

@end

@implementation LoginViewController

- (void)dealloc {
    NSLog(@"------------- %@ %@ -------------", [self class], NSStringFromSelector(_cmd));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"OneLogin";
    self.normalLoginButton.layer.masksToBounds = YES;
    self.normalLoginButton.layer.cornerRadius = 5;
    self.popupLoginButton.layer.masksToBounds = YES;
    self.popupLoginButton.layer.cornerRadius = 5;
    
    [OneLogin registerWithAppID:@"53cd718a9fd11e4dea99a22f138dc509"];
    [OneLogin setDelegate:self];
    [OneLogin preGetTokenWithCompletion:^(NSDictionary * _Nonnull sender) {
        NSLog(@"sender: %@", sender.description);
        NSNumber *status = [sender objectForKey:@"status"];
        if (status && [@(200) isEqualToNumber:status]) {
            // 预取号成功
            
        } else {
#warning 请处理预取号的错误, 更多错误码请参考错误码文档
            NSString *errCode   = [sender objectForKey:@"errorCode"];
            NSString *msg       = [sender objectForKey:@"msg"];
            NSString *processID = [sender objectForKey:@"processID"];
            NSString *appID     = [sender objectForKey:@"appID"];
            NSString *operator  = [sender objectForKey:@"operatorType"];
            
            NSLog(@"[Operator: %@] - [Error Code: %@] - [Message: %@] - [ProccesID: %@] - [APPID: %@]", operator, errCode, msg, processID, appID);
            
            // 预取号失败
            if ([@"-20101" isEqualToString:errCode]) {
                // TO-DO
                // 未配置 AppID，请通过 registerWithAppID: 配置 AppID
            }
            else if ([@"-20102" isEqualToString:errCode]) {
                // TO-DO
                // 重复调用 preGetTokenWithCompletion:
            }
            else if ([@"-20202" isEqualToString:errCode]) {
                // TO-DO
                // 检测到未开启蜂窝网络
            }
            else if ([@"-20203" isEqualToString:errCode]) {
                // TO-DO
                // 不支持的运营商类型
            }
            else {
                // TO-DO
                // 其他错误类型
            }
        }
    }];
}

#pragma mark - Screen Size

- (CGFloat)ol_screenWidth {
    return MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

- (CGFloat)ol_screenHeight {
    return MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

#pragma mark - Action

- (IBAction)normalLoginAction:(id)sender {
    // 若不需要自定义UI，可不设置任何参数，使用SDK默认配置即可
    OLAuthViewModel *viewModel = [OLAuthViewModel new];
    // -------------- 自定义UI设置 -----------------
    
#ifdef NeedCustomAuthUI
    // -------------- 授权页面背景图片设置 -------------------
    viewModel.backgroundImage = [UIImage imageNamed:@"login_back"];
    viewModel.landscapeBackgroundImage = [UIImage imageNamed:@"login_back_landscape"];
    
    // -------------- 导航栏设置 -------------------
    viewModel.naviTitle = [[NSAttributedString alloc] initWithString:@"一键登录"
                                                          attributes:@{NSForegroundColorAttributeName : UIColor.whiteColor,
                                                                       NSFontAttributeName : [UIFont boldSystemFontOfSize:18]
                                                                       }];  // 导航栏标题
    viewModel.naviBgColor = UIColor.greenColor; // 导航栏背景色
    viewModel.naviBackImage = [UIImage imageNamed:@"back"]; // 导航栏返回按钮
    viewModel.naviHidden = YES;  // 导航栏是否隐藏，默认不隐藏，注意，此处导航栏隐藏，不会隐藏返回按钮和标题，另，页面其他控件距顶部偏移，导航栏隐藏时，为到状态栏顶部的距离，导航栏不隐藏时，为到导航栏底部的距离
    viewModel.backButtonHidden = NO; // 是否隐藏返回按钮，默认不隐藏
    OLRect backButtonRect = {0, 0, 0, 0, 0, 0, {0, 0}}; // 返回按钮偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
    viewModel.backButtonRect = backButtonRect;
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightBarButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    viewModel.naviRightControl = rightBarButton;    // 导航栏右侧控制视图
    
    // -------------- logo设置 -------------------
    viewModel.appLogo = [UIImage imageNamed:@"网关取号_logo"];  // 自定义logo图片
    OLRect logoRect = {0, 0, 0, 20, 0, 0, {0, 0}}; // logo偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置，logo大小默认为图片大小
    viewModel.logoRect = logoRect;
    viewModel.logoHidden = NO; // 是否隐藏logo，默认不隐藏
    
    // -------------- 手机号设置 -------------------
    viewModel.phoneNumColor = UIColor.redColor; // 颜色
    viewModel.phoneNumFont = [UIFont boldSystemFontOfSize:25]; // 字体
    OLRect phoneNumRect = {0, 0, 0, 0, 0, 0, {0, 0}};  // 手机号偏移设置，手机号不支持设置宽高
    viewModel.phoneNumRect = phoneNumRect;
    
    // -------------- 切换账号设置 -------------------
    viewModel.switchButtonColor = UIColor.brownColor; // 切换按钮颜色
    viewModel.switchButtonFont = [UIFont systemFontOfSize:15];  // 切换按钮字体
    viewModel.switchButtonText = @"自定义切换按钮文案";  // 切换按钮文案
    viewModel.switchButtonHidden = NO; // 是否隐藏切换按钮，默认不隐藏
    OLRect switchButtonRect = {0, 0, 0, 0, 0, 0, {0, 0}};  // 切换按钮偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
    viewModel.switchButtonRect = switchButtonRect;
    
    // -------------- 授权登录按钮设置 -------------------
    viewModel.authButtonImages = @[
                                   [UIImage imageNamed:@"bg_logo_launch"],
                                   [UIImage imageNamed:@"bg_logo_launch"],
                                   [UIImage imageNamed:@"bg_logo_launch"]
                                   ];   // 授权按钮背景图片
    viewModel.authButtonTitle = [[NSAttributedString alloc] initWithString:@"授权登录"
                                                                attributes:@{NSForegroundColorAttributeName : UIColor.whiteColor,
                                                                             NSFontAttributeName : [UIFont boldSystemFontOfSize:18]
                                                                             }];  // 导航栏标题
    OLRect authButtonRect = {0, 0, 0, 0, 0, 0, {300, 40}};  // 授权按钮偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
    viewModel.authButtonRect = authButtonRect;
    
    // -------------- slogan设置 -------------------
    viewModel.sloganTextColor = UIColor.cyanColor; // slogan颜色
    viewModel.sloganTextFont = [UIFont systemFontOfSize:14]; // slogan字体
    OLRect sloganRect = {0, 0, 0, 0, 0, 0, {0, 0}};  // slogan偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
    viewModel.sloganRect = sloganRect;
    
    // -------------- 服务条款设置 -------------------
    viewModel.defaultCheckBoxState = YES; // 是否默认选择同意服务条款，默认同意
    //    viewModel.checkedImage = [UIImage imageNamed:@""]; // 复选框选中状态图片
    //    viewModel.uncheckedImage = [UIImage imageNamed:@""]; // 复选框未选中状态图片
    viewModel.checkBoxSize = CGSizeMake(12, 12); // 复选框尺寸，默认为12*12
    // 隐私条款文字属性
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 1.33;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.paragraphSpacing = 0.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.firstLineHeadIndent = 0.0;
    viewModel.privacyTermsAttributes = @{
                                         NSForegroundColorAttributeName : UIColor.orangeColor,
                                         NSParagraphStyleAttributeName : paragraphStyle,
                                         NSFontAttributeName : [UIFont systemFontOfSize:12]
                                         };
    // 额外自定义服务条款，注意index属性，默认的index为0，SDK会根据index对多条服务条款升序排列，假如想设置服务条款顺序为 自定义服务条款1 默认服务条款 自定义服务条款2，则，只需将自定义服务条款1的index设为-1，自定义服务条款2的index设为1即可
    OLPrivacyTermItem *item1 = [[OLPrivacyTermItem alloc] initWithTitle:@"自定义服务条款1"
                                                                linkURL:[NSURL URLWithString:@"https://www.baidu.com"]
                                                                  index:0
                                                                  block:^(OLPrivacyTermItem * _Nonnull termItem) {
                                                                      NSLog(@"termItem.termLink: %@", termItem.termLink);
                                                                      // 自定义操作，可进入自定义服务条款页面
                                                                  }];
    OLPrivacyTermItem *item2 = [[OLPrivacyTermItem alloc] initWithTitle:@"自定义服务条款2"
                                                                linkURL:[NSURL URLWithString:@"https://docs.geetest.com/"]
                                                                  index:0];
    viewModel.additionalPrivacyTerms = @[item1, item2];
    OLRect termsRect = {0, 0, 0, 0, 0, 0, {0, 0}};  // 服务条款偏移、大小设置，偏移量和大小设置值需大于0，否则取默认值，默认可不设置
    viewModel.termsRect = termsRect;
    viewModel.auxiliaryPrivacyWords = @[@"条款前文案", @"&", @"&", @"条款后的文案"];   // 条款之外的文案，默认可不设置
    
    // -------------- 服务条款H5页面导航栏设置 -------------------
    viewModel.webNaviTitle = [[NSAttributedString alloc] initWithString:@"服务条款"
                                                             attributes:@{NSForegroundColorAttributeName : UIColor.whiteColor,
                                                                          NSFontAttributeName : [UIFont boldSystemFontOfSize:18]
                                                                          }];  // 服务条款H5页面导航栏标题
    viewModel.webNaviBgColor = UIColor.purpleColor; // 服务条款导航栏背景色
    viewModel.webNaviHidden = NO;   // 服务条款导航栏是否隐藏
    
    // -------------- 授权页面支持的横竖屏设置 -------------------
    viewModel.supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown; // 默认为UIInterfaceOrientationMaskPortrait
    
    // -------------- 自定义UI设置，如，可以在授权页面添加三方登录入口 -------------------
    viewModel.customUIHandler = ^(UIView * _Nonnull customAreaView) {
        UIButton *customBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        [customBtn setTitle:@"我是自定义UI" forState:UIControlStateNormal];
        customBtn.backgroundColor = [UIColor redColor];
        customBtn.layer.cornerRadius = 2.0;
        [customBtn addTarget:self action:@selector(dismissAuthVC) forControlEvents:UIControlEventTouchUpInside];
        [customAreaView addSubview:customBtn];
        customBtn.center = CGPointMake(customAreaView.bounds.size.width/2, customAreaView.bounds.size.height/2 + 150);
    };
    
    // -------------- 授权页面点击登录按钮之后的loading设置 -------------------
    viewModel.loadingViewBlock = ^(UIView * _Nonnull containerView) {
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [containerView addSubview:indicatorView];
        indicatorView.center = CGPointMake(containerView.bounds.size.width/2, containerView.bounds.size.height/2);
        [indicatorView startAnimating];
    };
#endif
    
    __weak typeof(self) wself = self;
    [OneLogin requestTokenWithViewController:self viewModel:viewModel completion:^(NSDictionary * _Nullable result) {
        NSLog(@"requestTokenWithViewController result: %@", result);
        [wself finishRequestingToken:result];
    }];
}

- (void)doneAction:(UIButton *)button {
    [self dismissAuthVC];
}

- (IBAction)popupLoginAction:(id)sender {
    // 若不需要自定义UI，可不设置任何参数，使用SDK默认配置即可，但是弹窗模式时，isPopup一定要设置为YES
    OLAuthViewModel *viewModel = [OLAuthViewModel new];
    viewModel.isPopup = YES;
    
#ifdef NeedCustomAuthUI
    // 弹窗内的元素设置同- (IBAction)normalLoginAction:(id)sender 方法中的设置，这里紧示例弹窗自身的设置，如大小、偏移、动画
    // -------------- 弹窗设置 -------------------
    
    // 自定义弹窗动画
    viewModel.popupAnimationStyle = OLAuthPopupAnimationStyleCoverVertical; // 弹窗动画风格，支持CoverVertical、StyleFlipHorizontal、CrossDissolve和自定义模式，默认为CoverVertical
    CATransition *animation = [CATransition animation];
    animation.duration = 1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"rippleEffect";
    animation.subtype = kCATransitionFromLeft;
    viewModel.popupTransitionAnimation = animation; // 只有在popupAnimationStyle为OLAuthPopupAnimationStyleCustom时生效
    
    // 弹窗位置、大小设置，弹窗默认大小为300*340，居于屏幕中间，假如要弹窗居于底部，可做如下设置
    OLRect popupRect = {[self ol_screenHeight] - 340, 0, 0, 0, 0, 0, {[self ol_screenWidth], 340}};  // 弹窗偏移、大小设置
    viewModel.popupRect = popupRect;
    viewModel.popupCornerRadius = 0; // 弹窗圆角，默认为6
//    viewModel.closePopupImage = [UIImage imageNamed:@"back"]; // 关闭按钮
    viewModel.closePopupTopOffset = @(3);  // 关闭按钮距弹窗顶部偏移
    viewModel.closePopupRightOffset = @(-8); // 关闭按钮距弹窗右边偏移
#endif
    
    __weak typeof(self) wself = self;
    [OneLogin requestTokenWithViewController:self viewModel:viewModel completion:^(NSDictionary * _Nullable result) {
        NSLog(@"requestTokenWithViewController result: %@", result);
        [wself finishRequestingToken:result];
    }];
}

- (void)finishRequestingToken:(NSDictionary *)result {
    if (result.count > 0 && result[@"status"] && 200 == [result[@"status"] integerValue]) {
        NSString *token = result[@"token"];
        NSString *appID = result[@"appID"];
        NSString *processID = result[@"processID"];
        [self validateTokenAndGetLoginInfo:token appID:appID processID:processID];
    } else {
#warning 请处理获取token的错误, 更多错误码请参考错误码文档
        NSString *errCode   = [result objectForKey:@"errorCode"];
        NSString *msg       = [result objectForKey:@"msg"];
        NSString *processID = [result objectForKey:@"processID"];
        NSString *appID     = [result objectForKey:@"appID"];
        NSString *operator  = [result objectForKey:@"operatorType"];
        
        // 获取网关token失败
        if ([@"-20103" isEqualToString:errCode]) {
            // TO-DO
            // 重复调用 requestTokenWithViewController:viewModel:completion:
        }
        else if ([@"-20202" isEqualToString:errCode]) {
            // TO-DO
            // 检测到未开启蜂窝网络
        }
        else if ([@"-20203" isEqualToString:errCode]) {
            // TO-DO
            // 不支持的运营商类型
        }
        else if ([@"-20204" isEqualToString:errCode]) {
            // TO-DO
            // 未获取有效的 `accessCode`, 请确保先调用过 preGetTokenWithCompletion:
        }
        else if ([@"-20302" isEqualToString:errCode]) {
            // TO-DO
            // 用户点击了授权页面上的返回按钮, 授权页面将自动关闭
        }
        else if ([@"-20303" isEqualToString:errCode]) {
            // TO-DO
            // 用户点击了授权页面上的切换账号按钮, 授权页面不会自动给关闭。如需关闭, 需调用 [OneLogin dismissAuthViewController]。
        }
        else {
            // TO-DO
            // 其他错误类型
        }
        
        NSLog(@"[Operator: %@] - [Error Code: %@] - [Message: %@] - [ProccesID: %@] - [APPID: %@]", operator, errCode, msg, processID, appID);
        
        // 一键登录失败手动关闭授权页面
        [OneLogin dismissAuthViewController:nil];
    }
}

// 使用token获取用户的登录信息
- (void)validateTokenAndGetLoginInfo:(NSString *)token appID:(NSString *)appID processID:(NSString *)processID {
    // 根据用户自己接口构造
    // demo仅做演示
    // 请不要在线上使用该接口 `http://onepass.geetest.com/onelogin/result`
    
    NSURL *url = [NSURL URLWithString:@"http://onepass.geetest.com/onelogin/result"];
    //    NSURL *url = [NSURL URLWithString:@"http://115.28.227.76:8000/onelogin/result"];
    
    NSMutableURLRequest *mRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:(NSURLRequestCachePolicy)0 timeoutInterval:10.0];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:processID  forKey:@"process_id"];
    [params setValue:appID      forKey:@"id_2_sign"];
    [params setValue:token      forKey:@"token"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:(NSJSONWritingOptions)0 error:nil];
    
    mRequest.HTTPMethod = @"POST";
    mRequest.HTTPBody = data;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:mRequest
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         NSLog(@"result data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                         
                                         // 一键登录校验成功, 手动关闭授权页面
                                         [OneLogin dismissAuthViewController:nil];
                                     }] resume];
    
}

- (void)dismissAuthVC {
    [OneLogin dismissAuthViewController:nil];
}

#pragma mark - OneLoginDelegate

- (void)userDidSwitchAccount {
    [OneLogin dismissAuthViewController:nil];
}

- (void)userDidDismissAuthViewController {
    [OneLogin dismissAuthViewController:nil];
}

@end