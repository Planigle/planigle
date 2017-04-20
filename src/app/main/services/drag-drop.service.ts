import { Injectable } from '@angular/core';
declare var $: any;

@Injectable()
export class DragDropService {
  private dragSetup: DragSetup = null;

  setUpDragDrop(dropInstance: any, dropFunction: any, enableCopy?: boolean): void {
    if (this.dragSetup) {
      this.dragSetup.kill();
    }
    this.dragSetup = new DragSetup(dropInstance, dropFunction, enableCopy);
  }
}

class DragSetup {
  private scrollAmount = 150;
  private copy = false;
  private scrollingUp = false;
  private scrollingUpInterval = null;
  private scrollingDown = false;
  private scrollingDownInterval = null;
  private timeout = null;
  private bottom = 0;
  private mouseY = 0;
  private updatingBorder = false;
  private updatingBorderInterval = null;

  constructor(dropInstance: any, dropFunction: any, enableCopy?: boolean) {
    let self: DragSetup = this;
    $('.ag-row').draggable({
      appendTo: '.ag-body-viewport',
      zIndex: 100,
      axis: 'y',
      helper: 'clone',
      revert: 'invalid',
      start: function(event: any, ui: any) {
        if (enableCopy && event.ctrlKey) {
          self.copy = true;
          $('.ui-draggable-dragging').css('background', '#D4E5FD');
        }
        $('.scroll-up, .scroll-down').css('z-index', 10);
      },
      stop: function(event: any, ui: any) {
        $('.scroll-up, .scroll-down').css('z-index', -10);
      }
    }).droppable({
      greedy: true,
      drop: function(event, ui) {
        dropFunction.call(dropInstance, event, ui, $(this), self.copy);
      },
      tolerance: 'pointer'
    });

    $('.scroll-up').droppable({
      over: function(event: any, ui: any){
        if (!self.scrollingUp) {
          self.scrollingUp = true;
          if (!self.scrollingUpInterval) {
            self.scrollingUpInterval = setInterval(function() {
              let scroll: number = $('.ag-body-viewport').scrollTop();
              let diff: number = scroll < self.scrollAmount ? -scroll : -self.scrollAmount;
              if (diff < 0) {
                $('.ag-body-viewport').scrollTop(scroll + diff);
              }
            }, 200);
          }
        }
      },
      out: function(event: any, ui: any){
        self.stopScrollingUp();
      }
    });

    $('.scroll-down').droppable({
      drop: function(event, ui) {
        dropFunction.call(dropInstance, event, ui, $(this), self.copy);
      },
      over: function(event: any, ui: any){
        if (!self.scrollingDown) {
          self.scrollingDown = true;
          if (!self.scrollingDownInterval) {
            self.scrollingDownInterval = setInterval(function() {
              let scroll: number = $('.ag-body-viewport').scrollTop();
              let maxScroll: number = $('.ag-body-viewport').prop('scrollHeight') - $('.ag-body-viewport').innerHeight();
              let diff: number = scroll + self.scrollAmount > maxScroll ? (maxScroll - self.scrollAmount) : self.scrollAmount;
              if (diff > 0) {
                $('.ag-body-viewport').scrollTop(scroll + diff);
              }
            }, 200);
          }
        }
      },
      out: function(event: any, ui: any){
        self.stopScrollingDown();
      }
    });

    $('.ag-body-viewport').droppable({
      activate: function(event: any, ui: any){
        if (!self.updatingBorder) {
          self.updatingBorder = true;
          let lastRow = $('.ag-body-container .ag-row:last-child');
          self.bottom = lastRow.offset().top + lastRow.height();
          $(document).on('mousemove', function(mouseEvent) {
            self.mouseY = mouseEvent.pageY;
          });
          self.updatingBorderInterval = setInterval(function() {
            let row = $('.ag-body-container .ag-row:last-child');
            let newState = self.mouseY <= self.bottom ? '0px none rgb(0, 0, 0)' : '1px solid rgb(0, 0, 0)';
            if (row.css('border-bottom') !== newState) {
              row.css('border-bottom', newState);
            }
          }, 200);
        }
      },
      drop: function(event, ui) {
        dropFunction.call(dropInstance, event, ui, $(this), self.copy);
      },
      deactivate: function(event, ui) {
        self.deactivateBorder();
      }
    });
  }

  public kill() {
    this.stopScrollingUp();
    this.stopScrollingDown();
    this.deactivateBorder();
  }

  private stopScrollingUp() {
    this.scrollingUp = false;
    if (this.scrollingUpInterval !== null) {
      clearInterval(this.scrollingUpInterval);
      this.scrollingUpInterval = null;
    }
  }

  private stopScrollingDown() {
    this.scrollingDown = false;
    if (this.scrollingDownInterval !== null) {
      clearInterval(this.scrollingDownInterval);
      this.scrollingDownInterval = null;
    }
  }

  private deactivateBorder() {
    this.updatingBorder = false;
    $(document).off('mousemove');
    if (this.updatingBorderInterval !== null) {
      clearInterval(this.updatingBorderInterval);
      this.updatingBorderInterval = null;
    }
    $('.ag-body-container .ag-row:last-child').css('border-bottom', '0px none rgb(0, 0, 0)');
  }
}
