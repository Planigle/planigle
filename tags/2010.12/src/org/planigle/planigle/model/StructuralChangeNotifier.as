package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	public class StructuralChangeNotifier
	{
		private var watchers:ArrayCollection = new ArrayCollection();
		private static var instance:StructuralChangeNotifier;
		
		public function StructuralChangeNotifier(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One StructuralChangeNotifier");
		}

		// Returns the single instance.
		public static function getInstance():StructuralChangeNotifier
		{
			if (instance == null)
				instance = new StructuralChangeNotifier(new SingletonEnforcer);
			return instance;
		}
		
		public function addWatcher(func:Function):void
		{
			watchers.addItem(func);
		}
		
		public function structureChanged():void
		{
			for each (var func:Function in watchers)
				func.call();
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}