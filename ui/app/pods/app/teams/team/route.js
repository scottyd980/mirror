import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
  model(params) {
    var _this = this;
    return _this.get('store').findRecord('team', params.id).catch(() => {
      throw {type: "404", description: "Page Not Found", message: "We're sorry... we searched all over but couldn't find the page you were looking for!"};
    });
  }
});
