import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
  model(params) {
    var _this = this;
    return RSVP.hash({
      team: _this.get('store').findRecord('team', params.id).catch(() => { throw new Error('The team you were looking for was not found.') })
    });
  },
  setupController(controller, model) {

  }
});
