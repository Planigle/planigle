package org.planigle.planigle.control
{
	import com.adobe.cairngorm.control.FrontController;
	import org.planigle.planigle.events.*;
	import org.planigle.planigle.commands.*;
	
	public class IterationsController extends FrontController
	{
		public function IterationsController()
		{
			this.initialize();	
		}
		
		public function initialize():void
		{
			// Map event to command.
			this.addCommand(IterationChangedEvent.ITERATION_CHANGED, GetIterationsCommand);	
		}
	}
}