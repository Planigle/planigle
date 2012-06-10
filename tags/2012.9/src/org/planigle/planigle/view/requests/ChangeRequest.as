package org.planigle.planigle.view.requests
{
	public class ChangeRequest extends Request
	{
		protected var params:Object;

		public function ChangeRequest(item:Object, params:Object, notifySuccess:Function, notifyFailure: Function)
		{
			super(item, notifySuccess, notifyFailure);
			this.params = params;
		}

		override public function perform():void {
			item.update(params, notifySuccess, notifyFailure);
		}
	}
}