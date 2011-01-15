package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.CreateReleaseCommand;
	
	[Bindable]
	public class ReleaseFactory
	{
		public var currentId:String;
		public var timeUpdated:String;
		public var releases:ArrayCollection = new ArrayCollection();
		public var releaseSelector:ArrayCollection = new ArrayCollection();
		private var releaseMapping:Object = new Object();
		private static var instance:ReleaseFactory;
		
		public function ReleaseFactory(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One ReleaseFactory");
		}

		// Returns the single instance.
		public static function getInstance():ReleaseFactory
		{
			if (instance == null)
				instance = new ReleaseFactory(new SingletonEnforcer);
			return instance;
		}
		
		// Update my releases to be the specified releases.
		public function updateReleases( newReleases:ArrayCollection ):void
		{
			var newReleaseSelector:ArrayCollection = new ArrayCollection();
			releaseMapping = new Object();

			for each (var release:Release in newReleases)
			{
				newReleaseSelector.addItem(release);
				releaseMapping[release.id] = release;
			}
			
			var noRelease:Release = new Release();
			noRelease.name = "No Release";
			newReleaseSelector.addItem( noRelease );
			releases = newReleases;
			releaseSelector = newReleaseSelector;
		}

		// Populate the releases based on an Array of Releases.
		public function populate(timeUpdated:String, releases:Array):void
		{
			this.timeUpdated = timeUpdated;
			updateReleases(new ArrayCollection(releases));
		}
		
		// Create a new release.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an Array with errors).
		public function createRelease(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateReleaseCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// An release has been successfully created.  Change myself to reflect the changes.
		public function createCompleted(xml:XML):Release
		{
			var newRelease:Release = new Release();
			newRelease.populate(xml);
			// Create copy to ensure any views get notified of changes.
			var newReleases:ArrayCollection = new ArrayCollection();
			for each (var release:Release in releases)
				newReleases.addItem(release);
			newReleases.addItem(newRelease);
			updateReleases(newReleases);
			return newRelease;
		}

		// Find an release given its ID.  If no release, return an Release representing the backlog.
		public function find(id:String):Release
		{
			var release:Release = releaseMapping[id];
			return release ? release : Release(releaseSelector.getItemAt(releaseSelector.length-1));	
		}
		
		// Answer the first release whose dates include today.  If none, return null.
		public function current():Release
		{
			for (var i:int = releases.length - 1; i >= 0; i--)
			{ // go backwards
				var release:Release = Release(releases.getItemAt(i));
				if(release.isCurrent())
					return release;
			}
			return null;
		}
		
		// Answer the current release or if none, the most recent.  If no releases, return null.
		public function mostRecent():Release
		{
			var now:Date = DateUtils.today();
			var currentRelease:Release = null;
			for each (var release:Release in releases)
			{
				if (release.start <= now)
					currentRelease = release;
				else
					break;
			}
			return currentRelease;
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}