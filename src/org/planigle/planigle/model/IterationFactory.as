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

			for each (var iteration:Iteration in newIterations)
			{
				newIterationSelector.addItem(iteration);
				iterationMapping[iteration.id] = iteration;
			}
			
			var iter:Iteration = new Iteration();
			iter.populate( <iteration><id nil="true" /><name>Backlog</name></iteration> );
			newIterationSelector.addItem( iter );
			iterations = newIterations;
			iterationSelector = newIterationSelector;
		}

		// Populate the iterations.
		public function populate(newIterations:Array):void
		{
			updateIterations(new ArrayCollection(newIterations));
		}
		
		// Create a new iteration.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function createIteration(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new CreateIterationCommand(this, params, successFunction, failureFunction).execute(null);
		}
		
		// An iteration has been successfully created.  Change myself to reflect the changes.
		public function createCompleted(xml:XML):Iteration
		{
			var newIteration:Iteration = new Iteration();
			newIteration.populate(xml);
			// Create copy to ensure any views get notified of changes.
			var newIterations:ArrayCollection = new ArrayCollection();
			for each (var iteration:Iteration in iterations)
				newIterations.addItem(iteration);
			newIterations.addItem(newIteration);
			updateIterations(newIterations);
			return newIteration;
		}

		// Find an iteration given its ID.  If no iteration, return an Iteration representing the backlog.
		public function find(id:String):Iteration
		{
			var iteration:Iteration = iterationMapping[id];
			return iteration ? iteration : Iteration(iterationSelector.getItemAt(iterationSelector.length-1));	
		}
		
		// Answer the first iteration whose dates include today.  If none, return null.
		public function current():Iteration
		{
			for each (var iteration:Iteration in iterations)
			{
				if(iteration.isCurrent())
					return iteration;
			}
			return null;
		}

		// Answer the iterations within the release.
		public function iterationsInRelease(release:Release):ArrayCollection
		{
			var iterationsInRelease:ArrayCollection = new ArrayCollection();
			for each (var iteration:Iteration in iterationSelector)
			{
				if (!release.id || release.id == "-1" || !iteration.id || iteration.isIn(release))
					iterationsInRelease.addItem(iteration);
			}
			return iterationsInRelease;
		}

		// Answer the past n iterations (less if less have occurred).
		public function getPastIterations(num:int):ArrayCollection
		{
			var today:Date = new Date();
			var past:ArrayCollection = new ArrayCollection();
			for (var i:int=iterations.length - 1; i>=0; i--)
			{
				var iteration:Iteration = Iteration(iterations.getItemAt(i));
				if (iteration.end() < today)
				{
					past.addItemAt(iteration, 0);
					if (past.length == num)
						break;
				}
			}
			return past;
		}
	}
}

// Utility class to deny access to contructor.
class SingletonEnforcer {}