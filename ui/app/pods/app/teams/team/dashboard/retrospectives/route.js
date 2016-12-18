import Ember from 'ember';
import RSVP from 'rsvp';
import config from '../../../../../../config/environment';

export default Ember.Route.extend({
  socket: Ember.inject.service('socket-service'),
  retrospectiveService: Ember.inject.service('retrospective-service'),
  session: Ember.inject.service('session'),

  model() {
    var _this = this;
    return RSVP.hash({
      team: _this.modelFor('app.teams.team'),
      nextSprint: 3
    });
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('hasRetroInProgress', false);
    controller.set('isRetroStartModalShowing', false);

    var retro = this.get('retrospectiveService').join_team_channel(model.team.get('id'));

    controller.set('retrospective', retro);
  },
  setRetrospectiveInProgress(in_progress) {
    this.controller.set('hasRetroInProgress', in_progress);
  },
  moveToRetrospectiveInProgress(retrospective_id) {
    console.log(retrospective_id);
  },
  actions: {
    enterRetrospectiveType() {
      this.controller.set('isRetroStartModalShowing', true);
    },
    cancelEnterRetrospectiveType() {
      this.controller.set('isRetroStartModalShowing', false);
    },
    startRetrospective() {
      let retrospective = this.store.createRecord('retrospective')

      retrospective.set('name', 'Sprint ' + this.currentModel.nextSprint);
      retrospective.set('team', this.currentModel.team);
      retrospective.set('moderator', this.get('session').get('currentUser'));
      retrospective.set('isAnonymous', true);

      this.get('retrospectiveService').start(retrospective).then((result) => {
        this.controller.set('isRetroStartModalShowing', false);
      });
    },
    joinRetrospective(retrospective_id) {
      var _this = this;

      return fetch(`${config.DS.host}/${config.DS.namespace}/retrospective_users`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
          'Content-Type': 'application/vnd.api+json'
        },
        body: JSON.stringify({
          "retrospective_id": retrospective_id
        })
      }).then((response) => {
        if(response.status === config.STATUS_CODES.created || response.status === config.STATUS_CODES.ok) {
          response.json().then((resp) => {
            con
            _this.transitionTo('app.retrospectives.retrospective.start', resp.data.attributes.retrospective_id);
          });
        } else {
          if(response.status === config.STATUS_CODES.unprocessable_entity) {
            _this.get('notificationCenter').error({
              title: config.ERROR_MESSAGES.generic,
              message: "We experienced an unexpected error trying to join the retrospective. Please try again."
            });
          }
        }
      });
    }
  }
});
