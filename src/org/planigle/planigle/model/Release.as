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
	
		// Populate myself from another object.
		public function populate(release:Release):void
		{
			name = release.name;
			start = release.start;			
			finish = release.finish;
		}
	
		// Populate myself from another an object.
		public function populateFromObject(params:Object):void
		{
			if (params["record[project_id]"] != undefined) projectId = params["record[project_id]"];
			if (params["record[name]"] != undefined) name = params["record[name]"];
			if (params["record[start]"] != undefined) start = params["record[start]"] == "" ? null : params["record[start]"];
			if (params["record[finish]"] != undefined) finish = params["record[finish]"] == "" ? null : params["record[finish]"];
		}
		
		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			var newRelease:Release = Release(ObjectUtil.copy(this));
			newRelease.populateFromObject(params);
			new UpdateReleaseCommand(this, newRelease, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully updated.  Change myself to reflect the changes.
		public function updateCompleted(release:Release):void
		{
			populate(release);
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
			var today:Date = new Date();
			return today.time >= start.time && today.time <= finish.time;
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
	}
}