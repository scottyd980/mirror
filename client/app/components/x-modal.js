import Component from '@ember/component';
import $ from 'jquery';

export default Component.extend({
  tagName: "",
  didInsertElement() {
    this._super(...arguments);
    $('body').addClass('modal-open');
  },
  willDestroyElement() {
    this._super(...arguments);
    $('body').removeClass('modal-open');
  }
});
