package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	
	import org.planigle.planigle.model.Story;
	import org.planigle.planigle.model.Task;
	
	public class TasksDelegate
	{
		private var responder:IResponder;
		
		public function TasksDelegate( responder:IResponder )
		{
			this.responder = responder;
		}
		
		// Create the story as specified.
		public function createTask( story:Story, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("createTaskService");
			params['random'] = Math.random(); // Prevents caching
			service.url = "/stories/" + story.id + "/tasks.xml"
			service.send(params).addResponder( responder );
		}
		
		// Update the task as specified.
		public function updateTask( task:Task, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("updateTaskService");
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "PUT";
			service.url = "/stories/" + task.story.id + "/tasks/" + task.id + ".xml";
			service.send(params).addResponder( responder );
		}
		
		// Delete the task.
		public function deleteTask( task:Task ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("deleteTaskService");
			var params:Object = new Object();
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "DELETE";
			service.url = "/stories/" + task.story.id + "/tasks/" + task.id + ".xml";
			service.send(params).addResponder( responder );
		}
	}
}