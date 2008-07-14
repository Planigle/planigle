package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.adobe.cairngorm.model.ModelLocator;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.http.HTTPService;
	import mx.rpc.remoting.RemoteObject;
	import org.planigle.planigle.model.Project;
	
	public class ProjectsDelegate
	{
		// Required by Cairngorm delegate.
		private var responder:IResponder;
		
		public function ProjectsDelegate( responder:IResponder )
		{
			this.responder = responder;
		}
		
		// Get the latest projects.
		public function getProjects():void 
		{
			var remoteObject:RemoteObject = ServiceLocator.getInstance().getRemoteObject("projectRO");
			remoteObject.index.send().addResponder(responder);
		}	
		
		// Create the project as specified.
		public function createProject( params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("createProjectService");
			params['random'] = Math.random(); // Prevents caching
			service.send(params).addResponder( responder );
		}
		
		// Update the project as specified.
		public function updateProject( project:Project, params:Object ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("updateProjectService");
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "PUT";
			service.url = "projects/" + project.id + ".xml";
			service.send(params).addResponder( responder );
		}
		
		// Delete the project.
		public function deleteProject( project:Project ):void
		{
			var service:HTTPService = ServiceLocator.getInstance().getHTTPService("deleteProjectService");
			var params:Object = new Object();
			params['random'] = Math.random(); // Prevents caching
			params['_method'] = "DELETE";
			service.url = "projects/" + project.id + ".xml";
			service.send(params).addResponder( responder );
		}
	}
}