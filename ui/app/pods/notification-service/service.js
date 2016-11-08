import Ember from 'ember';

export default Ember.Service.extend({
  router: Ember.inject.service("-routing"),
  notifications: null,
  init() {
    this._super(...arguments);
    this.set('notifications', []);
  },
  error(notification) {
    notification.type = "error";
    this.get('notifications').pushObject(notification)
  },
  clear() {
    this.get('notifications').clear();
  },
  // currentRouteNameChanged: function(router, propertyName) {
  //   console.log(this.get('router').get("currentRouteName"));
  // }
  // onRouteChange: Ember.observer('router.currentRouteName', function(){
  //   console.log('route changed')
  // })
});
