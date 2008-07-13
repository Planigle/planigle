package org.planigle.planigle.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	
	import mx.rpc.IResponder;
	import mx.rpc.remoting.RemoteObject;
	
	import org.planigle.planigle.model.Release;
	
	public class ReleasesDelegate
	{
		// Required by Cairngorm delegate.
		private var remoteObject:RemoteObject;
		private var responder:IResponder;
		
		public function ReleasesDelegate( responder:IResponder )
		{
			this.responder = responder;
			this.remoteObject = ServiceLocator.getInstance().getRemoteObject("releaseRO");
		}
		
		// Get the latest releases.
		public function getReleases():void 
		{
			remoteObject.index.send().addResponder(responder);
		}	
		
		// Create the release as specified.
		public function createRelease( release:Release ):void
		{
			remoteObject.create.send(release).addResponder(responder);
		}
		
		// Update the release as specified.
		public function updateRelease( release:Release ):void
		{
			remoteObject.update.send(release).addResponder(responder);
		}
		
		// Delete the release.
		public function deleteRelease( release:Release ):void
		{
			remoteObject.destroy.send(release.id).addResponder(responder);
		}
	}
}