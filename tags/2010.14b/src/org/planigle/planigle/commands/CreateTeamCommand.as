package org.planigle.planigle.commands
{
	import org.planigle.planigle.business.Delegate;
	import org.planigle.planigle.business.TeamsDelegate;
		
	public class CreateTeamCommand extends CreateCommand
	{
		public function CreateTeamCommand(factory:Object, someParams:Object, aSuccessFunction:Function, aFailureFunction:Function, completedFunction:Function)
		{
			super(factory, someParams, aSuccessFunction, aFailureFunction, completedFunction);
		}

		// This should be overriden by subclasses to provide the specific delegate class.
		override protected function createDelegate():Delegate
		{
			return new TeamsDelegate( this )
		}
	}
}