import { PlaniglePage } from './app.po';

describe('planigle App', function() {
  let page: PlaniglePage;

  beforeEach(() => {
    page = new PlaniglePage();
  });

  it('should display message saying app works', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('app works!');
  });
});
