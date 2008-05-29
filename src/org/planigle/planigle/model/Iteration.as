package org.planigle.planigle.model
{
	import mx.collections.ArrayCollection;
	
	import org.planigle.planigle.commands.DeleteIterationCommand;
	import org.planigle.planigle.commands.UpdateIterationCommand;

	[Bindable]
	public class Iteration
	{
		private const MILLIS_IN_WEEK:int = 7*24*60*60*1000;
		public var id:int;
		public var name:String;
		public var start:Date;
		public var length:int;
	
		// Populate myself from XML.
		private function populate(xml:XML):void
		{
			id = xml.id;
			name = xml.name;
			
			try
			{
				var st:String = xml.start;
				st=st.replace(/-/g, "/");
				start = new Date(st);
			}
			catch(exception:TypeError)
			{
				start = new Date();
			}
			
			length = xml.length;
		}
		
		// Construct an iteration based on XML.
		public function Iteration(xml:XML)
		{
			populate(xml);
		}
		
		// Update me.  Params should be of the format (record[param]).  Success function
		// will be called if successfully updated.  FailureFunction will be called if failed (will
		// be passed an XMLList with errors).
		public function update(params:Object, successFunction:Function, failureFunction:Function):void
		{
			new UpdateIterationCommand(this, params, successFunction, failureFunction).execute(null);
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
			new DeleteIterationCommand(this, successFunction, failureFunction).execute(null);
		}
		
		// I have been successfully deleted.  Remove myself to reflect the changes.
		public function destroyCompleted():void
		{
			// Create copy to ensure any views get notified of changes.
			var iterations:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < IterationFactory.getInstance().iterations.length; i++)
			{
				var iteration:Iteration = Iteration(IterationFactory.getInstance().iterations.getItemAt(i));
				if (iteration != this)
					iterations.addItem(iteration);
			}
			IterationFactory.getInstance().updateIterations(iterations);
		}
		
		// Answer my end date
		public function end():Date
		{
			return new Date(start.time + length * MILLIS_IN_WEEK);
		}
		
		// Answer true if my dates include today.
		public function isCurrent():Boolean
		{
			var today:Date = new Date();
			return today.time > start.time && today.time < start.time + length * MILLIS_IN_WEEK;
		}
		
		// Answer the next iteration after this one.  If I am the backlog, return myself.
		public function next():Iteration
		{
			var iterations:ArrayCollection = IterationFactory.getInstance().iterationSelector;
			var i:int = iterations.getItemIndex( this );
			if (i < iterations.length - 1)
				return Iteration(iterations.getItemAt( i + 1 ));
			else
				return this;
		}
	}
}