import Ember from 'ember';

export default Ember.Component.extend({
  didInsertElement() {
    this._super(...arguments);
    Ember.$('body').addClass('modal-open');
  },
  willDestroyElement() {
    this._super(...arguments);
    Ember.$('body').removeClass('modal-open');
  },
  actions: {
    close() {
      this.get('notifications').clear();
    }
  }
});
