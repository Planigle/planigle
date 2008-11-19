package org.planigle.planigle.commands
{
	import org.planigle.planigle.business.Delegate;
	import org.planigle.planigle.business.StoryAttributesDelegate;
		
	public class CreateStoryAttributeCommand extends CreateCommand
	{
		public function CreateStoryAttributeCommand(factory:Object, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function, completedFunction:Function)
		{
			super(factory, someParams, aSuccessFunction, aFailureFunction, completedFunction);
		}

		// This should be overriden by subclasses to provide the specific delegate class.
		override protected function createDelegate():Delegate
		{
			return new StoryAttributesDelegate( this )
		}
	}
}