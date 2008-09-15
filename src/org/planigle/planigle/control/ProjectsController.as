package org.planigle.planigle.control
{
	import com.adobe.cairngorm.control.FrontController;
	import org.planigle.planigle.commands.GetProjectsCommand;
	import org.planigle.planigle.events.ProjectChangedEvent;
	
	public class ProjectsController extends FrontController
	{
		public function ProjectsController()
		{
			this.initialize();	
		}
		
		public function initialize():void
		{
			// Map event to command.
			this.addCommand(ProjectChangedEvent.PROJECT_CHANGED, GetProjectsCommand);	
		}
	}
}