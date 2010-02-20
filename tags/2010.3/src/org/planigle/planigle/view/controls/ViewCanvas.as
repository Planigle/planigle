package org.planigle.planigle.view.controls
{
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.events.CloseEvent;

	public class ViewCanvas extends Canvas
	{
		public function ViewCanvas()
		{
			super();
		}
		
		/**
		 * Answer whether the user has made any changes. By default, be conservative and assume that
		 * they have.
		 */
		public function isDirty():Boolean
		{
			return true;
		}
		
		/**
		 * Check whether the user has made changes.  If so, ask them if they want to lose them.
		 * If no changes or ok to lose call func.
		 */
		public function checkDirty(func:Function):void
		{
			if (isDirty())
			{
				Alert.show("Are you sure you want to lose your changes?", "Changes", 3, this,
					function(event:CloseEvent):void
					{
						if (event.detail!=Alert.NO)
							func.call(this);
					});
			}
			else
				func.call(this);
		}
	}
}