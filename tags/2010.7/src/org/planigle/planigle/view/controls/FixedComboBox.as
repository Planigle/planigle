/*
Written by Ben Atkins (http://www.batkins.net)

Any person obtaining this code may use/modify/distribute/re-use it as they please without limitation

This is a fixed version of the ComboBox component that fixes a bug that occurs when using the ComboBox component
on an application that uses version 3.5 of the Flex SDK.  This bug does not occur in version 3.4.1 or earlier, and has been
fixed in version 3.6.0.13209.  This class is intended to serve as a workaround to the bug while using the 3.5 SDK.  
Once a stable version of the 3.6 SDK is released we can revert back to using the standard ComboBox component and back
all instances of this out of the code.

For more information on the bug, see:
https://bugs.adobe.com/jira/browse/SDK-25705
https://bugs.adobe.com/jira/browse/SDK-25567

Here is the corresponding comment for the checkin which was made by klin@adobe.com on 12/23/09:

"Adding same fix for SDK-23838 and SDK-24205 to 3.x from trunk. 

The dropDown was not receiving changes to styles nor dataproviders. This was a result of not recreating the dropDown each time it was shown. 
I've changed the default of the flag for destroying the dropDown to be true. I've also modified the code to only not destroy the dropDown 
when it is showing or being shown. Iâ€™ve also moved some of the code in the animation handler to check for a null dropDown first before 
destroying it.

QE notes: No
Doc notes: No
Bugs: SDK-23838, SDK-24205
Reviewer: Jason
Tests run: checkintests, ComboBox
Is noteworthy for integration: No"
*/

package org.planigle.planigle.view.controls
{
	import flash.events.Event;
	
	import mx.controls.ComboBox;
	import mx.controls.listClasses.ListBase;
	import mx.events.ResizeEvent;

	public class FixedComboBox extends ComboBox
	{
		//this will replace the list base on an update
		private var newDropDown:ListBase;
		
		public function FixedComboBox()
		{
			super();
			
			this.addEventListener(ResizeEvent.RESIZE, onResize);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		//This addresses the problem where the list base wasn't reflecting changes to the data provider
		override public function set dataProvider(value:Object):void
		{
			super.dataProvider = value;
			newDropDown = dropdown;
			
			if(newDropDown)
			{
				validateSize(true);
				newDropDown.dataProvider = super.dataProvider;
			}
		}
		
		//this addresses problems where the listbase wasn't resizing properly
		private function onResize(event:ResizeEvent):void
		{
			if (newDropDown)
				newDropDown.width = this.width;
		}
		
		//this addresses a problem where the ListBase it would improperly resize if it was removed from the stage and brought back
		private function onAddedToStage(event:Event):void
		{
			if (newDropDown)
				newDropDown.validateSize(true);
		}	
	}
}