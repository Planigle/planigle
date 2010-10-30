package org.planigle.planigle.view.requests
{
	import org.planigle.planigle.model.Story;	
	import org.planigle.planigle.model.Task;	

	public class CopyTaskRequest extends Request
	{
		protected var priority:Number;
		protected var story:Story;
		
		public function CopyTaskRequest(item:Task, story:Story, priority:Number, notifySuccess:Function, notifyFailure: Function)
		{
			super(item, notifySuccess, notifyFailure);
			this.priority = priority;
			this.story = story;
		}

		override public function perform():void {
			item.copy(story, priority, notifySuccess, notifyFailure);
		}
	}
}