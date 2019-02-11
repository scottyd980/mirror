import Component from '@ember/component';
import $ from 'jquery';

export default Component.extend({
  dragOver(event) {
    event.preventDefault();
  },
  classNames: ["drop-zone"],
  drop(event) {
    $('.drop-zone').removeClass('dz-border');
    var id = event.dataTransfer.getData('text/data');
    this.onDrop(id, this.get('data'));
  }
});