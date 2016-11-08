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
  error(notification) {
    notification.type = "error";
    this.get('notifications').pushObject(notification)
  },
  clear() {
    this.get('notifications').clear();
  },
  currentPathDidChange: function(newUrl) {
    console.log(newUrl);
    this.clear();
  }
  // onRouteChange: Ember.observer('router.currentRouteName', function(){
  //   console.log('route changed')
  // })
});
