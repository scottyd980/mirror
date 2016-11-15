import Ember from 'ember';
import config from '../../../../../../config/environment';

export default Ember.Route.extend({
  socket: Ember.inject.service('socket-service'),
  setupController(controller, model) {
    this._super(controller, model);

    this.get('socket').connect();
  }
});
