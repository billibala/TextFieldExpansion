//
//  MyTextField.m
//  TextFieldExpansion
//
//  Created by Bill So on 6/21/15.
//  Copyright © 2015 Bill So. All rights reserved.
//

#import "MyTextField.h"

@interface MyTextField () {
	BOOL editingField;
	BOOL firstPass;
	BOOL preservesCustomIntrinsicSize;
	NSSize customIntrinsicSize;
	NSSize textEditorSize;
}

@end

@implementation MyTextField

- (void)textDidBeginEditing:(NSNotification *)notification;
{
	[super textDidBeginEditing:notification];
	editingField = YES;
	firstPass = YES;
}

- (void)textDidEndEditing:(NSNotification *)notification;
{
	[super textDidEndEditing:notification];
	editingField = NO;
}

- (void)textDidChange:(NSNotification *)notification {
	[super textDidChange:notification];
	/*
	 2015-06-21 18:42:30.231 TextFieldExpansion[8329:684931] NSConcreteNotification 0x618000043a50 {name = NSTextDidChangeNotification; object = <NSTextView: 0x6100001205a0>
	 Frame = {{2.00, 3.00}, {436.00, 17.00}}, Bounds = {{0.00, 0.00}, {436.00, 17.00}}
	 Horizontally resizable: NO, Vertically resizable: YES
	 MinSize = {436.00, 17.00}, MaxSize = {40000.00, 40000.00}
	 }
	 2015-06-21 18:42:32.367 TextFieldExpansion[8329:684931] NSConcreteNotification 0x60000004c270 {name = NSTextDidChangeNotification; object = <NSTextView: 0x6100001205a0>
	 Frame = {{2.00, 3.00}, {436.00, 34.00}}, Bounds = {{0.00, 0.00}, {436.00, 34.00}}
	 Horizontally resizable: NO, Vertically resizable: YES
	 MinSize = {436.00, 17.00}, MaxSize = {40000.00, 40000.00}
	 }
	 
	 Bounds of the text view change as content changes
	 */
	NSTextView * textView = notification.object;
	if ( firstPass ) {
		// initialize values
		firstPass = NO;
		textEditorSize = textView.bounds.size;
		return;
	}
	
	NSSize currentSize = textView.bounds.size;
	if ( !NSEqualSizes(currentSize, textEditorSize) ) {
		if (ABS(currentSize.height - textEditorSize.height) < 5.0) {
			// instrinsic size of the text field affects the size of the text editor as well. If, after adjusting text field's intrinisc size, the resulting size of the text editor has small difference with the intended size, ignore it.
			textEditorSize = currentSize;
			return;
		}
		// size of the editing content has changed.
		// invalidate intrinsic size of the text field.
		//
		// NOTE: http://asciiwwdc.com/2013/sessions/210
		textEditorSize = currentSize;
		[self invalidateIntrinsicContentSize];
	}
}

- (NSSize)intrinsicContentSize {
	if ( editingField ) {
		NSRect editorRect = self.currentEditor.frame;
		customIntrinsicSize = NSMakeSize(editorRect.origin.x * 2.0 + textEditorSize.width, editorRect.origin.y * 2.0 + textEditorSize.height);
		preservesCustomIntrinsicSize = YES;
		return customIntrinsicSize;
	}
	
	return preservesCustomIntrinsicSize ? customIntrinsicSize : [super intrinsicContentSize];
}

@end
