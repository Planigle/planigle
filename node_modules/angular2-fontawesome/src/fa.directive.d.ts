import { ElementRef, SimpleChange } from '@angular/core';
export declare class FaDirective {
    static sizeValidator: RegExp;
    static flipValidator: RegExp;
    static pullValidator: RegExp;
    static rotateValidator: RegExp;
    private name;
    private alt;
    private size;
    private stack;
    private flip;
    private pull;
    private rotate;
    private border;
    private spin;
    private fw;
    private inverse;
    private el;
    constructor(el: ElementRef);
    ngOnChanges(changes: {
        [propertyName: string]: SimpleChange;
    }): void;
}
