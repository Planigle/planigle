package org.planigle.planigle.view
{
	import mx.collections.ArrayCollection;
	
	public class Node
	{
		protected var model:Object;
		public var parent: Object;
		public var children: ArrayCollection;
		protected var subset: ArrayCollection;

		public function Node(parent:Object, model:Object, levels:int, subset:ArrayCollection)
		{
			this.parent = parent;
			this.model = model;
			this.children = new ArrayCollection();
			this.subset = subset;
			
			if (levels > 1)
			{
				for each (var child:Object in model.children)
					addNode(child, levels - 1);
			}
			
			var source:Array = children.source;
			source.sortOn(["rawUtilization", "capacity", "utilized", "name"], [Array.NUMERIC | Array.DESCENDING, Array.NUMERIC | Array.DESCENDING, Array.NUMERIC | Array.DESCENDING, Array.CASEINSENSITIVE]);
			children = new ArrayCollection(source);
			
			if (children.length == 0)
				children = null;
		}
		
		// Add a sub-node.
		protected function addNode(object:Object, levels:int):void
		{
		}
		
		// Answer how much I can be utilized.
		public function get capacity():Number
		{
			return 0;
		}
		
		// Answer how much I am utilized in the subset.
		public function get utilized():Number
		{
			return 0;
		}
		
		public function get name():String
		{
			return model.name;
		}
		
		// Answer the color to use.
		public function get color():uint
		{
			var used:Number = utilized;
			var total:Number = capacity;
			if (total > 0)
			{
				var percent:int = 100 * used / total;
				return percent > 100 ? 0xFF0000 : 0x000000;
			}
			return used > 0 ? 0xFF0000 : 0x000000;
		}

		// Answer the utilization as a number.
		public function get rawUtilization():Number
		{
			var used:Number = utilized;
			var total:Number = capacity;
			return total > 0 ? used / total : 0;
		}

		// Answer the utilization as a string.
		public function get utilization():String
		{
			var used:Number = utilized;
			var total:Number = capacity;
			if (total > 0)
			{
				var percent:int = 100 * used / total;
				return formatNumber(used) + " of " + formatNumber(total) + " (" + percent + "%) - " + model.name;
			}
			else
				return formatNumber(used) + " of 0 - " + name;
		}

		// Format a number for display.
		private function formatNumber(num:Number):String
		{
			var base:String = num.toFixed(2);
			if (base.charAt(base.length-1) == "0" && base.charAt(base.length-2) == "0")
				return base.substring(0,base.length-3);
			else if (base.charAt(base.length-1) == "0")
				return base.substring(0,base.length-1);
			else
				return base;
		}
	}
}