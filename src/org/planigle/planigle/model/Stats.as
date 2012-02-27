package org.planigle.planigle.model
{
	[Bindable]
	public class Stats
	{
		public static var instance:Stats;
		public var storyStats:Object = new Object();
		
		public function Stats(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One Stats object");
		}

		// Returns the single instance.
		public static function getInstance():Stats
		{
			if (instance == null)
				instance = new Stats(new SingletonEnforcer);
			return instance;
		}
		
		public function populate(stats:Object):void
		{
			storyStats = stats == null ? new Object() : stats;
		}
		
		public function getStatuses(team:Team):Object
		{
			if(int(team.id) == -1)
			{
				var combined:Object = new Object();
				for(var id:String in storyStats)
				{
					var statuses:Object = getSubcategory(storyStats[id],"statuses");
					for(var status:String in statuses)
					{
						if(combined[status] == null)
							combined[status] = 0;
						combined[status] += statuses[status];
					}
				}
				return combined;
			} else return getSubcategory(storyStats[team.id],"statuses");
		}
		
		public function getIterations(team:Team):Object
		{
			if(int(team.id) == -1)
			{
				var combined:Object = new Object();
				for(var id:String in storyStats)
				{
					var iterations:Object = getSubcategory(storyStats[id],"iterations");
					for(var iteration:String in iterations)
					{
						if(combined[iteration] == null)
							combined[iteration] = 0;
						combined[iteration] += iterations[iteration];
					}
				}
				return combined;
			} else return getSubcategory(storyStats[team.id],"iterations");
		}
		
		protected function getSubcategory(stats:Object, subcategory:String):Object
		{
			return stats == null ? null : stats[subcategory];
		}
		
		public function getNotStarted(team:Team):Number
		{
			var stats:Object = getStatuses(team);
			return stats == null ? 0 : stats[Story.CREATED];
		}
		
		public function getInProgress(team:Team):Number
		{
			var stats:Object = getStatuses(team);
			return stats == null ? 0 : stats[Story.IN_PROGRESS];
		}
		
		public function getBlocked(team:Team):Number
		{
			var stats:Object = getStatuses(team);
			return stats == null ? 0 : stats[Story.BLOCKED];
		}
		
		public function getDone(team:Team):Number
		{
			var stats:Object = getStatuses(team);
			return stats == null ? 0 : stats[Story.ACCEPTED];
		}
		
		public function getAssignedPoints(iteration:Iteration, team:Team):Number
		{
			var stats:Object = getIterations(team);
			return stats == null ? 0 : (stats[iteration.id] == null ? 0 : stats[iteration.id]);
		}
	}
}
	
// Utility class to deny access to contructor.
class SingletonEnforcer {}