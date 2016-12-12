import Ember from 'ember';
//import RSVP from 'rsvp';
import config from '../../../../config/environment';

export default Ember.Route.extend({
  socket: Ember.inject.service('socket-service'),
  model(params) {
    var _this = this;
    return _this.get('store').findRecord('team', params.id).catch(() => {
      throw config.ERROR_CODES.not_found;
    });
  },
  setupController(controller, model) {
    this._super(controller, model);
  }
});
