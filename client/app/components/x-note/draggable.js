import NoteComponent from 'mirror/components/x-note';
import $ from 'jquery';

export default NoteComponent.extend({
  attributeBindings: ['isModerator:draggable'],
  dragStart: function (event) {
    event.dataTransfer.setData("text/data", this.get('data.id'));
    $('.drop-zone').addClass('dz-border');
  },
  dragEnd: function () {
    $('.drop-zone').removeClass('dz-border');
  }
});