package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.CreateIterationCommand;
	
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
		
		// Update my iterations to be the specified iterations.
		public function updateIterations( newIterations:ArrayCollection ):void
		{
			var newIterationSelector:ArrayCollection = new ArrayCollection();
			iterationMapping = new Object();

			for (var i:int = 0; i < newIterations.length; i++)
			{
				var iteration:Iteration = Iteration(newIterations.getItemAt(i));
				newIterationSelector.addItem(iteration);
				iterationMapping[iteration.id] = iteration;
			}
			
			newIterationSelector.addItem( new Iteration( <iteration><id nil="true" /><name>Backlog</name></iteration> ) );
			iterations = newIterations;
			iterationSelector = newIterationSelector;
		}

		// Populate the iterations based on XML.
		public function populate(xml:XMLList):void
		{
			var newIterations:ArrayCollection = new ArrayCollection();
			for (var j:int = 0; j < xml.length(); j++)
				newIterations.addItem(new Iteration(xml[j]));
			updateIterations(newIterations);
		}
		
		// Create a new iteration.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createIteration(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateIterationCommand(params, successFunction, failureFunction).execute(null);
		}
		
		// An iteration has been successfully created.  Change myself to reflect the changes.
		public function createIterationCompleted(xml:XML):Iteration
		{
			var iteration:Iteration = new Iteration(xml);
			// Create copy to ensure any views get notified of changes.
			var newIterations:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < iterations.length; i++)
				newIterations.addItem(iterations.getItemAt(i));
			newIterations.addItem(iteration);
			updateIterations(newIterations);
			return iteration;
		}

		// Find an iteration given its ID.  If no iteration, return an Iteration representing the backlog.
		public function find(id:int):Iteration
		{
			var iteration:Iteration = iterationMapping[id];
			return iteration ? iteration : Iteration(iterationSelector.getItemAt(iterationSelector.length-1));	
		}
		
		// Answer the first iteration whose dates include today.  If none, return null.
		public function current():Iteration
		{
			for (var i:int = 0; i < iterations.length; i++)
			{
				var iteration:Iteration = Iteration(iterations.getItemAt(i));
				if(iteration.isCurrent())
					return iteration;
			}
			return null;
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}