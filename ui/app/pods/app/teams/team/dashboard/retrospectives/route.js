import Ember from 'ember';
import RSVP from 'rsvp';
import config from '../../../../../../config/environment';

export default Ember.Route.extend({
  socket: Ember.inject.service('socket-service'),
  model() {
    var _this = this;
    return RSVP.hash({
      team: _this.modelFor('app.teams.team')
    });
  },
  setupController(controller, model) {
    this._super(controller, model);

    controller.set('hasRetroInProgress', false);
    controller.set('isRetroStartModalShowing', false);

    let chan = this.get('socket').joinChannel(`team:${model.team.get('id')}`);

    //chan.push('inProgress');

    chan.on('inProgress', (data) => {
      controller.set('hasRetroInProgress', true);
    });
  },
  actions: {
    enterRetrospectiveType() {
      this.controller.set('isRetroStartModalShowing', true);
    },
    cancelEnterRetrospectiveType() {
      this.controller.set('isRetroStartModalShowing', false);
    }
  }
});
