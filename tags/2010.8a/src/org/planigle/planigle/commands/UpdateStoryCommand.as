package org.planigle.planigle.commands
{
	import org.planigle.planigle.business.Delegate;
	import org.planigle.planigle.business.StoriesDelegate;

	public class UpdateStoryCommand extends UpdateCommand
	{
		public function UpdateStoryCommand(object:Object, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			super(object, someParams, aSuccessFunction, aFailureFunction);
		}

		// This should be overriden by subclasses to provide the specific delegate class.
		override protected function createDelegate():Delegate
		{
			return new StoriesDelegate( this )
		}
	}
}