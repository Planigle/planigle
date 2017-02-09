import { PipeTransform, Pipe, Injectable } from '@angular/core';

@Pipe({
    name: 'filter',
    pure: false
})
@Injectable()
export class FilterPipe implements PipeTransform {
    transform(items: any[], args: any[]): any {
        // filter items array, items which match and return true will be kept, false will be filtered out
        return items.filter((item: any) => {
          for (let key in args) {
            if (args.hasOwnProperty(key)) {
              if (args[key] !== item[key]) {
                return false;
              }
            }
          }
          return true;
        });
    }
}
