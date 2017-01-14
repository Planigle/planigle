import { Directive, ElementRef, OnInit } from '@angular/core';
@Directive({ selector: '[auto-select]' })
export class AutoSelectDirective implements OnInit {
  constructor(private element: ElementRef) {
  }

  ngOnInit() {
    let self: AutoSelectDirective = this;
    this.element.nativeElement.focus();
    setTimeout(() => self.element.nativeElement.select());
  }
}
