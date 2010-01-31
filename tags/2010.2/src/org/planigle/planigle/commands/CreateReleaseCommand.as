package org.planigle.planigle.commands
{
	import org.planigle.planigle.business.Delegate;
	import org.planigle.planigle.business.ReleasesDelegate;
		
	public class CreateReleaseCommand extends CreateCommand
	{
		public function CreateReleaseCommand(factory:Object, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			super(factory, someParams, aSuccessFunction, aFailureFunction);
		}

		// This should be overriden by subclasses to provide the specific delegate class.
		override protected function createDelegate():Delegate
		{
			return new ReleasesDelegate( this )
		}
	}
}