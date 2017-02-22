import { Injectable } from '@angular/core';
declare var $: any;

@Injectable()
export class DragDropService {
  setUpDragDrop(dropInstance: any, dropFunction: any, enableCopy?: boolean): void {
    let interval: any = null;
    const scrollAmount = 150;
    let copy = false;
    $('.ag-row').draggable({
      appendTo: '.ag-body-viewport',
      zIndex: 100,
      axis: 'y',
      helper: 'clone',
      revert: 'invalid',
      start: function(event: any, ui: any) {
        if (enableCopy && event.ctrlKey) {
          copy = true;
          $('.ui-draggable-dragging').css('background', '#D4E5FD');
        }
        $('.scroll-up, .scroll-down').css('z-index', 10);
      },
      stop: function(event: any, ui: any) {
        $('.scroll-up, .scroll-down').css('z-index', -10);
      }
    }).droppable({
      drop: function(event, ui) {
        dropFunction.call(dropInstance, event, ui, $(this), copy);
      },
      tolerance: 'pointer'
    });
    $('.scroll-up').droppable({
      over: function(event: any, ui: any){
        interval = setInterval(function() {
          let scroll: number = $('.ag-body-viewport').scrollTop();
          let diff: number = scroll < scrollAmount ? -scroll : -scrollAmount;
          if (diff < 0) {
            $('.ag-body-viewport').scrollTop(scroll + diff);
          }
        }, 200);
      },
      out: function(event: any, ui: any){
        if (interval !== null) {
          clearInterval(interval);
          interval = null;
        }
      }
    });

    $('.scroll-down').droppable({
      drop: function(event, ui) {
        dropFunction.call(dropInstance, event, ui, $(this), copy);
      },
      over: function(event: any, ui: any){
        interval = setInterval(function() {
          let scroll: number = $('.ag-body-viewport').scrollTop();
          let maxScroll: number = $('.ag-body-viewport').prop('scrollHeight') - $('.ag-body-viewport').innerHeight();
          let diff: number = scroll + scrollAmount > maxScroll ? (maxScroll - scrollAmount) : scrollAmount;
          if (diff > 0) {
            $('.ag-body-viewport').scrollTop(scroll + diff);
          }
        }, 200);
      },
      out: function(event: any, ui: any){
        if (interval !== null) {
          clearInterval(interval);
          interval = null;
        }
      }
    });
  }
}
