import Ember from 'ember';

export default Ember.Component.extend({
  notifications: Ember.inject.service('notification-service'),
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
