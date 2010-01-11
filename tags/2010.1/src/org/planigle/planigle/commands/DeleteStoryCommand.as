package org.planigle.planigle.commands
{
	import org.planigle.planigle.business.Delegate;
	import org.planigle.planigle.business.StoriesDelegate;

	public class DeleteStoryCommand extends DeleteCommand
	{
		public function DeleteStoryCommand(object:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			super(object, aSuccessFunction, aFailureFunction);
		}

		// This should be overriden by subclasses to provide the specific delegate class.
		override protected function createDelegate():Delegate
		{
			return new StoriesDelegate( this )
		}
	}
}