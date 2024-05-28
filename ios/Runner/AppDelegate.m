#import <Flutter/Flutter.h>
#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "CameraView.h"

@interface CameraViewFactory : NSObject <FlutterPlatformViewFactory>
@property (nonatomic, strong) CameraView *cameraView; // Retain the CameraView instance
@end

@implementation CameraViewFactory

- (instancetype)init {
    self = [super init];
    if (self) {
        _cameraView = [[CameraView alloc] initWithFrame:CGRectZero viewIdentifier:0 arguments:nil];
    }
    return self;
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
    return self.cameraView;
}

@end

@implementation AppDelegate {
    CameraViewFactory *cameraViewFactory;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    FlutterViewController *controller = (FlutterViewController *)self.window.rootViewController;

    // Register the plugin with the engine
    [GeneratedPluginRegistrant registerWithRegistry:controller.engine];

    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"com.example.flutterino/stream" binaryMessenger:controller.binaryMessenger];
    [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"startVideoRecording" isEqualToString:call.method]) {
            NSLog(@"[DEBUG] startVideoRecording method call received");
            [cameraViewFactory.cameraView startVideoRecordingWithResult:result];
            [channel invokeMethod:@"RECORDING_STARTED" arguments:nil];
        } else if ([@"stopVideoRecording" isEqualToString:call.method]) {
            NSLog(@"[DEBUG] stopVideoRecording method call received");
            [cameraViewFactory.cameraView stopVideoRecordingWithResult:result];
            [channel invokeMethod:@"RECORDING_STOPPED" arguments:nil];
        } else if ([@"foto_ios" isEqualToString:call.method]) {
            NSLog(@"[DEBUG] foto_ios method call received");
            [cameraViewFactory.cameraView capturePhotoWithResult:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];

    // Initialize and retain a single CameraView instance
    cameraViewFactory = [[CameraViewFactory alloc] init];
    NSObject<FlutterPluginRegistrar> *registrar = [controller.engine registrarForPlugin:@"CameraViewFactory"];
    [registrar registerViewFactory:cameraViewFactory withId:@"my_uikit_view"];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
