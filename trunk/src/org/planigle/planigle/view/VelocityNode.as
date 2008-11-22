package org.planigle.planigle.view
{
	import mx.collections.ArrayCollection;

	public class VelocityNode extends Node
	{
		public function VelocityNode(parent:Object, model:Object, levels:int, subset:ArrayCollection)
		{
			super(parent, model, levels, subset);
		}
		
		// Add a sub-node.
		protected override function addNode(object:Object, levels:int):void
		{
			children.addItem(new VelocityNode(this, object, levels, subset));
		}
		
		// Answer how much I can be utilized.
		public override function get capacity():Number
		{
			return model.velocity;
		}
		
		// Answer how much I am utilized in the subset.
		public override function get utilized():Number
		{
			return model.velocityIn(subset);
		}
	}
}