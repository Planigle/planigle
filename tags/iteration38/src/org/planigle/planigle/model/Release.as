package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	
	import org.planigle.planigle.commands.DeleteReleaseCommand;
	import org.planigle.planigle.commands.UpdateReleaseCommand;

	[RemoteClass(alias='Release')]
	[Bindable]
	public class Release
	{
		public var id:String;
		public var projectId: int;
		public var name:String;
		public var start:Date;
		public var finish:Date;
	
		// Populate myself from XML.
		public function populate(xml:XML):void
		{
			id = xml.id.toString() == "" ? null: xml.id;
			projectId = xml.child("project-id").toString() == "" ? null : xml.child("project-id");
			name = xml.name;
			start = DateUtils.stringToDate(xml.start);		
			finish = DateUtils.stringToDate(xml.finish);
		}
	
		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateReleaseCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(xml:XML):void
		{
			populate(xml);
		}
		
		// Delete me.  Success function if successfully deleted.  FailureFunction will be called if failed
		// (will be passed an Array with errors).
		public function destroy(successFunction:Function, failureFunction:Function):void
		{
			new DeleteReleaseCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			// Update stories.
			for each (var story:Story in StoryFactory.getInstance().stories)
			{
				if (story.releaseId == id)
					story.releaseId = null;
			}

			// Create copy to ensure any views get notified of changes.
			var releases:ArrayCollection = new ArrayCollection();
			for each (var release:Release in ReleaseFactory.getInstance().releases)
			{
				if (release != this)
					releases.addItem(release);
			}
			ReleaseFactory.getInstance().updateReleases(releases);
		}
		
		// Answer true if my dates include today.
		public function isCurrent():Boolean
		{
			var today:Date = DateUtils.today();
			return today.time >= start.time && today.time < finish.time;
		}

		// Answer true if I am active on a given date (true if any part of me overlaps).
		public function isActiveOn(date:Date):Boolean
		{
			return start <= date && finish > date;
		}
		
		// Increment my name (or return an empty string if I cannot do so).
		// Must end in numerics separated by .'s.  If one part, increment it.  If two or more, increment
		// second part.
		public function incrementName():String
		{
			var splits:Array = name.split(" ");
			var splits2:Array = splits[splits.length-1].split(".");
			if (splits2.length == 1)
			{ // If number is an integer, just increment it
				if (int(splits2[0]) > 0)
					splits[0] = (int(splits2[0]) + 1).toString();
			}
			else
			{ // If number has multiple parts, increment second part
				if (int(splits2[1]) > 0 || splits2[1] == '0')
					splits2[1] = (int(splits2[1]) + 1).toString();
				splits[splits.length-1] = splits2.join(".");
			}
			var newName:String = splits.join(" ");
			return name == newName ? "" : newName;
		}
		
		// Answer whether I am a release.
		public function isRelease():Boolean
		{
			return true;
		}
	}
}