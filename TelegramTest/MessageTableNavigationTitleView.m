 //
//  MessageTableNavigationTitleView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableNavigationTitleView.h"
#import "TLEncryptedChat+Extensions.h"
#import "TGTimer.h"
#import "ImageUtils.h"
#import "TGAnimationBlockDelegate.h"
#import "TGTimerTarget.h"
#import "ITSwitch.h"
#import "TGContextMessagesvViewController.h"
@interface MessageTableNavigationTitleView()<TMTextFieldDelegate, TMSearchTextFieldDelegate>
@property (nonatomic, strong) TMNameTextField *nameTextField;
@property (nonatomic, strong) TMStatusTextField *statusTextField;
@property (nonatomic, strong) NSMutableAttributedString *attributedString;

@property (nonatomic,strong) TMTextField *typingTextField;


@property (nonatomic,strong) TMView *container;

@property (nonatomic,strong) BTRButton *searchButton;



@end



@implementation MessageTableNavigationTitleView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
                
        self.container = [[TMView alloc] initWithFrame:self.bounds];
        self.container.wantsLayer = YES;
        
        self.typingTextField = [TMTextField defaultTextField];
        
        self.typingTextField.fieldDelegate = self;
        
        self.nameTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(0, 3, 0, 0)];
        [self.nameTextField setAlignment:NSCenterTextAlignment];
        [self.nameTextField setAutoresizingMask:NSViewWidthSizable];
        [self.nameTextField setFont:TGSystemFont(14)];
        [self.nameTextField setTextColor:NSColorFromRGB(0x222222)];
        [self.nameTextField setSelector:@selector(titleForMessage)];
        [self.nameTextField setEncryptedSelector:@selector(encryptedTitleForMessage)];
        [[self.nameTextField cell] setTruncatesLastVisibleLine:YES];
        [[self.nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameTextField setDrawsBackground:NO];
        [self.nameTextField setNameDelegate:self];
        [self.container addSubview:self.nameTextField];
    
        self.statusTextField = [[TMStatusTextField alloc] initWithFrame:NSMakeRect(0, 3, 0, 0)];
        [self.statusTextField setSelector:@selector(statusForMessagesHeaderView)];
        [self.statusTextField setAlignment:NSCenterTextAlignment];
        [self.statusTextField setStatusDelegate:self];
        [self.statusTextField setDrawsBackground:NO];
        
        [self.statusTextField setFont:TGSystemFont(12)];
        [self.statusTextField setTextColor:GRAY_TEXT_COLOR];
        
        //[self.statusTextField setBackgroundColor:NSColorFromRGB(0x000000)];
        
        [self.container addSubview:self.statusTextField];
        
        _searchButton = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(self.container.frame) - image_SearchMessages().size.width - 30, 0, image_SearchMessages().size.width +10, image_SearchMessages().size.height+10)];
        
        weak();
        
        [_searchButton addBlock:^(BTRControlEvents events) {
            
            if(![weakSelf.controller searchBoxIsVisible]) {
                [weakSelf.controller showSearchBox];
            }
            
        } forControlEvents:BTRControlEventClick];
        
        [_searchButton setImage:image_SearchMessages() forControlState:BTRControlStateNormal];
        
        [_searchButton setToolTip:@"CMD + F"];
        
        [self.container addSubview:_searchButton];
        
        [self addSubview:self.container];
        

        
        [Notification addObserver:self selector:@selector(chatFlagsUpdated:) name:CHAT_FLAGS_UPDATED];
        
    }
    return self;
}

-(void)chatFlagsUpdated:(NSNotification *)notification {
    
    if(self.dialog.chat == notification.userInfo[KEY_CHAT]) {
        [self setDialog:_dialog];
    }
}



-(void)setFrameSize:(NSSize)newSize {
    
    
    if(!CGRectIsEmpty(self.frame) && ![self inLiveResize]) {
        int dif = (NSWidth(self.frame) - newSize.width)/2.0f;
        
        [_searchButton setFrameOrigin:NSMakePoint(NSMinX(_searchButton.frame) - dif, 10)];
        
    } else {
        [_searchButton setFrameOrigin:NSMakePoint(newSize.width - image_SearchMessages().size.width - 10, 10)];
    }
    [super setFrameSize:newSize];
    
    [self buildForSize:newSize];
}

-(void)textFieldDidChange:(id)field {
   [self buildForSize:self.bounds.size];
}

- (void)setDialog:(TL_conversation *)dialog {
    self->_dialog = dialog;
    
    [_searchButton setFrameOrigin:NSMakePoint(NSWidth(self.frame) - image_SearchMessages().size.width - 10, 10)];
   // [_searchButton setHidden:self.dialog.type == DialogTypeChannel];
    
    
    [self.nameTextField updateWithConversation:self.dialog];

    [self.statusTextField updateWithConversation:self.dialog];
    


}

-(void)setController:(MessagesViewController *)controller {
    _controller = controller;
    
    [_searchButton setHidden:controller.class == [TGContextMessagesvViewController class]];
}

-(void)setState:(MessagesViewControllerState)state {
    _state = state;
}



- (void)buildForSize:(NSSize)size {
    
    [self.container setFrameSize:size];
        

    [self.nameTextField sizeToFit];
    
    [self.nameTextField setFrameSize:NSMakeSize(MIN(NSWidth(self.frame) - 60,NSWidth(self.nameTextField.frame)), NSHeight(self.nameTextField.frame))];
    
    [_nameTextField setCenteredXByView:_nameTextField.superview];
    [_nameTextField setFrameOrigin:NSMakePoint(NSMinX(_nameTextField.frame), self.bounds.size.height - self.nameTextField.bounds.size.height - 6)];
    

  //  [self.statusTextField setFrame:NSMakeRect(10, 9, self.bounds.size.width - 40, self.statusTextField.frame.size.height)];
    
    [self.statusTextField setFrameOrigin:NSMakePoint(NSMinX(self.statusTextField.frame), 7)];
    
    
   [self.statusTextField sizeToFit];
    [self.statusTextField setCenteredXByView:self.statusTextField.superview];
   
    
    

}

- (void) TMStatusTextFieldDidChanged:(TMStatusTextField *)textField {
    [self.statusTextField sizeToFit];
    [self buildForSize:self.bounds.size];
}

- (void) TMNameTextFieldDidChanged:(TMNameTextField *)textField {
    [self buildForSize:self.bounds.size];
}





- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    if(self.tapBlock)
        self.tapBlock();
    
}

@end
