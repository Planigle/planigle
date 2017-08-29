import { Component, Input } from '@angular/core';
import { Individual } from '../../models/individual';
import { Story } from '../../models/story';

@Component({
  selector: 'app-edit-comments',
  templateUrl: './edit-comments.component.html',
  styleUrls: ['./edit-comments.component.css']
})
export class EditCommentsComponent {
  @Input() me: Individual;
  @Input() story: Story;

  constructor() { }
}
