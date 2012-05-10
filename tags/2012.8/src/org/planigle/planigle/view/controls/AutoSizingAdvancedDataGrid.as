package org.planigle.planigle.view.controls
{
	import flash.geom.Point;
	
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderInfo;
	import mx.controls.listClasses.ListRowInfo;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	/**
	 * See http://workdayui.wordpress.com/2008/05/09/autosizingadvanceddatagrid-that-fixes-the-variablerowheight-issues-with-mxcontrolsadvanceddatagrid/
	 * When variableRowHeight is set to true on AdvancedDataGrid, 
	 * 
	 * (a) mx.controls.AdvancedDataGrid ignores attributes such as rowCount.
	 * (b) there is no way to figure out the height of the AdvancedDataGrid instance because we don't know how much height we will need to 
	 * show the rows of data in our dataProvider.  We can set the height to maxHeight but what of the sum of heights of all rows 
	 * in our grid is less than the maxHeight, we need our grid to adjust itself to the shorter height but the AdvancedDataGrid does not.  
	 * (c) When opening/closing trees in hierarchical data inside the grid, we need the grid to automatically adjust its height.  AdvancedDataGrid
	 * does not do that when variableRowHeight == true
	 */
	public class AutoSizingAdvancedDataGrid extends AdvancedDataGrid
	{
		public function AutoSizingAdvancedDataGrid()
		{
			super();
			this.defaultRowCount = 0;
		}
		protected var contentHeight:int = 0;
		/**
		 * Adjusts the height of the grid until it either runs out of the rows to draw or reaches maxHeight (if maxHeight has been set)
		 */
		 protected function getMeasuredHeight(maxHeight:int):Number 
		 {
			/*if the collection has only one row, we ignore the maxHeight by setting it back to its default
			One row cannot scroll, setting a max on that for one very large row (that is more than maxHeight pixels long) will force the 
			row to be cliped */
			var count:int = (collection)?collection.length:0;
			if ( count < 0 ) count = 0;
			if ( collection && count == 1 ) maxHeight = DEFAULT_MAX_HEIGHT;
			if ( contentHeight >= maxHeight ) return maxHeight;
			var hh:int = 0;
			if ( !rowInfo || rowInfo.length == 0 ) {
				if ( collection ) {
					contentHeight = Math.min(maxHeight,count * 20);
				} else 
					contentHeight = 0;
				return contentHeight;
			}
			/* keep on increasing the height until either we run out of rows to draw or maxHeight is reached */
			var len:int = Math.min(rowInfo.length,count);
			 for ( var i:int=0;i<len;i++ ) {
				 if ( rowInfo[i] && ListRowInfo(rowInfo[i]).uid ) {
					 hh += ListRowInfo(rowInfo[i]).height;
				 }
			 }		

			 /* if hh is less than maxHeight and we still have rows to show, increase the height */
			 if ( hh < maxHeight && rowInfo.length < count ) {
				 /* if we have already drawn all the rows without hitting the maxHeight, we are good to go */
				 hh = Math.min(maxHeight,hh + (count - rowInfo.length)*20);
			 }
			 contentHeight = Math.min(maxHeight,hh);
			return contentHeight;
		}	 
		protected function measureHeight():void 
		{
			var buffer:int = ((this.horizontalScrollBar!=null)?this.horizontalScrollBar.height:0);
			var maxContentHeight:int = maxHeight - (headerHeight + buffer);
			var listContentHeight:int = this.headerHeight + buffer + getMeasuredHeight(maxContentHeight);
			var hh:int = listContentHeight + 2;
			if ( hh == this.height ) return;
			calculatedListContentHeight = listContentHeight;
			calculatedHeight = hh;
			calculatedHeightChanged=true;
			invalidateProperties();
		}
		/**
		 * Override of the corresponding method in mx.controls.AdvancedDataGrid.  After drawing the rows, it calls measureHeight to figure out if 
		 * the height of the grid still needs to be adjusted
		 */
		 protected override function makeRowsAndColumns(left:Number, top:Number, right:Number, bottom:Number, firstCol:int, firstRow:int, byCount:Boolean=false, rowsNeeded:uint=0.0):Point 
		 {
			var p:Point = super.makeRowsAndColumns(left,top,right,bottom,firstCol,firstRow,byCount,rowsNeeded);
			measureHeight();
			return p;
		}	
		/**
		 * Override of the method from AdvancedDataGridBaseEx.configureScrollBars.  
		 * We copy the method but make one significant change - we comment out the code that
		 * pushes the scroll bar up if any filler rows are present.  With our variableRowHeights,
		 * this code sometimes pushes up the vertical scroll when the user is trying to scroll
		 * down.  In the worst case, it doesn't allow the user to see the last few rows.
		 */ 
		override protected function configureScrollBars():void
		{
			var oldHorizontalScrollBar:Object = horizontalScrollBar;
			var oldVerticalScrollBar:Object = verticalScrollBar;
	
			var rowCount:int = listItems.length;
			if (rowCount+headerItems.length== 0)////TODO
			{
				// Get rid of any existing scrollbars.
				if (oldHorizontalScrollBar || oldVerticalScrollBar)
					setScrollBarProperties(0, 0, 0, 0);
	
				return;
			}
	
			var vScrollProperties:Array;
			var hScrollProperties:Array;
	
			// partial last rows don't count
			if (rowCount > 1 && rowInfo[rowCount - 1].y + rowInfo[rowCount - 1].height > listContent.height)
				rowCount--;
	
			// offset, when added to rowCount, is the index of the dataProvider
			// item for that row.  IOW, row 10 in listItems is showing dataProvider
			// item 10 + verticalScrollPosition - lockedRowCount;
			var offset:int = verticalScrollPosition - lockedRowCount;
			// don't count filler rows at the bottom either.
			var fillerRows:int = 0;
			while (rowCount && listItems[rowCount - 1].length == 0)
			{
				// as long as we're past the end of the collection, add up
				// fillerRows
				if (collection && rowCount + offset >= collection.length)
				{
					rowCount--;
					++fillerRows;
				}
				else
					break;
			}
	
/*			 // we have to scroll up.  We can't have filler rows unless the scrollPosition is 0
			if (verticalScrollPosition > 0
					&& verticalScrollPosition != maxVerticalScrollPosition
					&& fillerRows > 0)
			{
				if (adjustVerticalScrollPositionDownward(Math.max(rowCount, 1)))
					return;
			} */
	
			vScrollProperties = [collection ? collection.length - lockedRowCount : 0,
											Math.max(rowCount - lockedRowCount, 1)];
			 
			 
			var colCount:int = visibleColumns.length;
			var lastHeaderInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(visibleColumns[visibleColumns.length - 1]);
			var headerPosX:int =  lastHeaderInfo.headerItem.x;
			if(visibleColumns.length - 1  > lockedColumnCount)
				headerPosX = getAdjustedXPos(headerPosX);
			
			// if the last column is visible and partially offscreen (but it isn't the only
			// column) then adjust the column count so we can scroll to see it
			if (colCount > 1 && visibleColumns[colCount - 1] == displayableColumns[displayableColumns.length - 1]
				&& headerPosX + visibleColumns[colCount - 1].width > displayWidth)
			{
				colCount--;
			}
			
			hScrollProperties = [displayableColumns.length - lockedColumnCount,
								 Math.max(colCount - lockedColumnCount, 1)];
	
			
			//Finally set both the scroll bar properties
			setScrollBarProperties(hScrollProperties[0], hScrollProperties[1],
								   vScrollProperties[0], vScrollProperties[1]);
			
			if ((!verticalScrollBar || !verticalScrollBar.visible) && collection &&
				collection.length - lockedRowCount > rowCount - lockedRowCount)
				maxVerticalScrollPosition = collection.length - lockedRowCount - (rowCount - lockedRowCount);
			
			if ((!horizontalScrollBar || !horizontalScrollBar.visible) && 
				displayableColumns.length - lockedColumnCount  > colCount - lockedColumnCount)
				maxHorizontalScrollPosition = displayableColumns.length - lockedColumnCount - (colCount - lockedColumnCount);
	
		}	
		/**
		* displayWidth is a private variable in mx.controls.AdvancedDataGridBaseEx.  We need to create it here so that we can 
		* use it
		*/
		protected var displayWidth:Number;
		/**
		 * We need to override the updateDisplayList so that we can set the displayWidth.  
		 * See the displayWidth variable in mx.controls.AdvancedDataGridBaseEx
		 */
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			if (displayWidth != unscaledWidth - viewMetrics.right - viewMetrics.left) {
				displayWidth = unscaledWidth - viewMetrics.right - viewMetrics.left;
			}
			super.updateDisplayList(unscaledWidth, unscaledHeight);					
		}					

		private var calculatedHeight:int=0;
		private var calculatedListContentHeight:int=0;
		private var calculatedHeightChanged:Boolean=false;
		
		override protected function commitProperties():void {
			super.commitProperties();
			if(calculatedHeightChanged){
				verticalScrollPosition=0;
				calculatedHeightChanged=false;
				height=calculatedHeight;
				listContent.height=calculatedListContentHeight;
				if ( height >= maxHeight ) {
					this.verticalScrollPolicy = "auto";
				}
				else this.verticalScrollPolicy = "off";		
			}
		}
	}
}