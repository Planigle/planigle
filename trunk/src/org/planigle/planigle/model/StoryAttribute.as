package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.DeleteStoryAttributeCommand;
	import org.planigle.planigle.commands.UpdateStoryAttributeCommand;
	
	[RemoteClass(alias='StoryAttribute')]
	[Bindable]
	public class StoryAttribute
	{
		public var id:int;
		public var project:Project;
		public var projectId:int;
		public var name:String;
		public var valueType:int;
		private var myStoryAttributeValues:Array = new Array();
		public static const STRING:int = 0;
		public static const TEXT:int = 1;
		public static const NUMBER:int = 2;
		public static const LIST:int = 3;
		public static const RELEASE_LIST:int = 4;

		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			projectId = xml.child("project-id").toString() == "" ? null : xml.child("project-id");
			id = xml.id;
			name = xml.name;
			valueType = xml.child("value-type");

			var newValues:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < xml.child("story-attribute-values").child("story-attribute-value").length(); i++)
			{
				var value:StoryAttributeValue = new StoryAttributeValue();
				value.populate(XML(xml.child("story-attribute-values").child("story-attribute-value")[i]));
				newValues.addItem(value);
			}
			storyAttributeValues = newValues.toArray();
		}

		// Answer my tasks.
		public function get storyAttributeValues():Array
		{
			return myStoryAttributeValues;
		}

		// Set my tasks.
		public function set storyAttributeValues(values:Array):void
		{
			values.sortOn(["value"], [Array.CASEINSENSITIVE]);
			myStoryAttributeValues = values;
		}

		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateStoryAttributeCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			populate(xml);
		}
		
		// Delete me.  Success function if successfully deleted.  FailureFunction will be called if failed
		// (will be passed an XMLList with errors).
		public function destroy(successFunction:Function, failureFunction:Function):void
		{
			new DeleteStoryAttributeCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			// Create copy to ensure any views get notified of changes.
			var storyAttributes:ArrayCollection = new ArrayCollection();
			for each (var storyAttribute:StoryAttribute in IndividualFactory.current().project.storyAttributes)
			{
				if (storyAttribute != this)
					storyAttributes.addItem(storyAttribute);
			}
			IndividualFactory.current().project.storyAttributes = storyAttributes.source;
		}
	}
}