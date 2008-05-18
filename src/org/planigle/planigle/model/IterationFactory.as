package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class IterationFactory
	{
		public var iterations:ArrayCollection = new ArrayCollection();
		public var iterationSelector:ArrayCollection = new ArrayCollection();
		private var iterationMapping:Object = new Object();
		private static var instance:IterationFactory;
		
		public function IterationFactory(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) 
				throw new Error("You Can Only Have One IterationFactory");
		}

		// Returns the single instance.
		public static function getInstance():IterationFactory
		{
			if (instance == null)
				instance = new IterationFactory(new SingletonEnforcer);
			return instance;
		}

		// Populate the iterations based on XML.
		public function populate(xml:XMLList):void
		{
			var newIterations:ArrayCollection = new ArrayCollection();
			var newIterationSelector:ArrayCollection = new ArrayCollection();
			iterationMapping = new Object();
			newIterationSelector.addItem( new Iteration( <iteration><id nil="true" /><name>Backlog</name></iteration> ) );

			for (var j:int = 0; j < xml.length(); j++)
			{
				var iteration:Iteration = new Iteration(xml[j]);
				newIterations.addItem(iteration);
				newIterationSelector.addItem(iteration);
				iterationMapping[iteration.id] = iteration;
			}
			
			iterations = newIterations;
			iterationSelector = newIterationSelector;
		}

		// Find an iteration given its ID.  If no iteration, return an Iteration representing the backlog.
		public function find(id:int):Iteration
		{
			var iteration:Iteration = iterationMapping[id];
			return iteration ? iteration : Iteration(iterationSelector.getItemAt(0));	
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}