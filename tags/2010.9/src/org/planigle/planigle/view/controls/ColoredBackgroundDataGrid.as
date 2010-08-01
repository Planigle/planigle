package org.planigle.planigle.view.controls
{
	import flash.display.Sprite;
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;

    // This class extends DataGrid and overrides the drawRowBackground function to use the new property: rowColorFunction.
	public class ColoredBackgroundDataGrid extends DataGrid
	{
		public function ColoredBackgroundDataGrid()
		{
			super();
		}
		
		// The rowColorFunction can be assigned any function which returns a color. The signature of the
		// function is:
		// 
		// 	function rowColorFunction( item:Object, color:uint ) : uint
		// 
		// The color parameter is the color that would normally be assigned (eg, one of the alternating 
		// row colors). The item is the data record for the row. If item is null, it means the row has
		// no data and is just a filler row.
		public var rowColorFunction:Function;
		
		// This function is responsible for drawing the background of the row. In this class, if the
		// rowColorFunction has been defined, it is called to pick the color. Otherwise the given
		// color is used.
		override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
		{
			if( rowColorFunction != null ) {
				var dp:ArrayCollection = dataProvider as ArrayCollection;
				var item:Object;
				if( dataIndex < dp.length ) item = dp.getItemAt(dataIndex);
				color = rowColorFunction( item, color );
			}
			super.drawRowBackground(s,rowIndex,y,height,color,dataIndex);
		}
	}
}