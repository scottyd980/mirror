import Ember from 'ember';

export default Ember.Service.extend(Ember.Evented, {
  routing: Ember.inject.service("-routing"),
  notifications: null,
  init() {
    this._super(...arguments);
    this.set('notifications', []);
    const router = this.get('routing.router');
    router.on('didTransition', (transition) => {
      this.currentPathDidChange(router.get('url'));
    })
  },
  success(notification) {
    this.clear();
    notification.type = "success";
    this.get('notifications').pushObject(notification);
  },
  error(notification) {
    this.clear();
    notification.type = "error";
    this.get('notifications').pushObject(notification);
  },
  confirm(notification) {
    this.clear();
    notification.type = "confirm";
    this.get('notifications').pushObject(notification);
  },
  clear() {
    this.get('notifications').clear();
  },
  currentPathDidChange: function(newUrl) {
    this.clear();
  }
});