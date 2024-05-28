#import "ViewController.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"[DEBUG] ViewController viewDidLoad");
    
    self.camera = [Camera sharedCamera];
    self.camera.delegate = self;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, WIDTH, (0.75) * WIDTH)];
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, HEIGHT - 50, WIDTH - 20, 1)];
    [self.view addSubview:line];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"[DEBUG] ViewController viewDidAppear");
    [self.camera start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.camera stop];
}

- (void)camera:(Camera *)server image:(UIImage *)image appendix:(NSString *)appendix {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
        self.capturedImage = image;
    });
}

- (UIImage *)getCurrentFrame {
    return self.imageView.image;
}

@end
