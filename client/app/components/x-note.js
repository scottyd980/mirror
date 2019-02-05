import Component from '@ember/component';
import $ from 'jquery';

export default Component.extend({
  attributeBindings: ['isModerator:draggable'],
  classNames: ['note'],
  classNameBindings: ['type'],
  isModerator: null,
  isAnonymous: null,
  type: '',
  dragStart: function (event) {
    event.dataTransfer.setData("text/data", this.get('data.id'));
    $('.drop-zone').addClass('dz-border');
  },
  dragEnd: function () {
    $('.drop-zone').removeClass('dz-border');
  }
});