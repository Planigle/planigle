package org.planigle.planigle.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class StoriesChangedEvent extends Event
	{
		public var stories:ArrayCollection;
		
		public function StoriesChangedEvent(stories:ArrayCollection)
		{
			super("dataChanged");
			this.stories = stories;
		}
	}
}