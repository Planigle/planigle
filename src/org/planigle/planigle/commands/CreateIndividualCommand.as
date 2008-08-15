package org.planigle.planigle.commands
{
	import org.planigle.planigle.business.Delegate;
	import org.planigle.planigle.business.IndividualsDelegate;
		
	public class CreateIndividualCommand extends CreateCommand
	{
		public function CreateIndividualCommand(factory:Object, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			super(factory, someParams, aSuccessFunction, aFailureFunction);
		}

		// This should be overriden by subclasses to provide the specific delegate class.
		override protected function createDelegate():Delegate
		{
			return new IndividualsDelegate( this )
		}
	}
}