package org.planigle.planigle.commands
{
	import org.planigle.planigle.business.Delegate;
	import org.planigle.planigle.business.StoryAttributesDelegate;

	public class DeleteStoryAttributeCommand extends DeleteCommand
	{
		public function DeleteStoryAttributeCommand(object:Object, aSuccessFunction:Function, aFailureFunction:Function)
		{
			super(object, aSuccessFunction, aFailureFunction);
		}

		// This should be overriden by subclasses to provide the specific delegate class.
		override protected function createDelegate():Delegate
		{
			return new StoryAttributesDelegate( this )
		}
	}
}