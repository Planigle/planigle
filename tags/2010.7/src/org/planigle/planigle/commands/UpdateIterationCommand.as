package org.planigle.planigle.commands
{
	import org.planigle.planigle.business.Delegate;
	import org.planigle.planigle.business.IterationsDelegate;

	public class UpdateIterationCommand extends UpdateCommand
	{
		public function UpdateIterationCommand(object:Object, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			super(object, someParams, aSuccessFunction, aFailureFunction);
		}

		// This should be overriden by subclasses to provide the specific delegate class.
		override protected function createDelegate():Delegate
		{
			return new IterationsDelegate( this )
		}
	}
}