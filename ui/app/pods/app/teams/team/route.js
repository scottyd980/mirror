import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
  model(params) {
    var _this = this;
    return RSVP.hash({
      team: _this.get('store').findRecord('team', params.id)
    });
  },
  setupController(controller, model) {
    console.log(model);
  },
  actions: {
    error(error, transition) {
      if(error) {
        this.transitionTo('error');
      }
    }
  }
});
