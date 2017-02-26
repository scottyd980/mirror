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
      nextSprint: fetch(`${config.DS.host}/${config.DS.namespace}/teams/${this.modelFor('app.teams.team').get('id')}/next_sprint`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
          'Content-Type': 'application/vnd.api+json'
        }
      }).then((response) => {
        return response.json();
      }).then((data) => {
        return data.next_sprint;
      }),
      currentUser: _this.get('session').get('currentUser')
    });
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('hasRetroInProgress', false);
    controller.set('isRetroStartModalShowing', false);
    controller.set('isBillingModalShowing', false);
    controller.set('gameToStart', null);
    controller.set('isAdmin', model.team.get('admins').includes(model.currentUser));

    var retro = this.get('retrospectiveService').join_team_channel(model.team.get('id'));

    controller.set('retrospective', retro);
  },
  actions: {
    enterRetrospectiveType(game_to_start) {
      this.controller.set('isRetroStartModalShowing', true);
      this.controller.set('gameToStart', game_to_start);
    },
    cancelEnterRetrospectiveType() {
      this.controller.set('isRetroStartModalShowing', false);
    },
    toggleBillingModal() {
      this.controller.toggleProperty('isBillingModalShowing');
    },
    startRetrospective(game) {
      let retrospective = this.store.createRecord('retrospective')

      retrospective.set('name', 'Sprint ' + this.currentModel.nextSprint);
      retrospective.set('team', this.currentModel.team);
      retrospective.set('moderator', this.get('session').get('currentUser'));
      retrospective.set('isAnonymous', true);
      retrospective.set('type', config.retrospective[this.controller.get('gameToStart')].type_id);

      this.get('retrospectiveService').start(retrospective).then((result) => {
        this.send('joinRetrospective', result.id);
      }).catch((error) => {
        if(error.errors[0].code === 403) {
          this.send('cancelEnterRetrospectiveType');
          this.send('toggleBillingModal');
        } else {
          this.get('notificationCenter').error({
            title: config.ERROR_MESSAGES.generic,
            message: "We experienced an unexpected error trying to join the retrospective. Please try again."
          });
        }
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
            // Always direct to start, the retrospective controller will handle additional re-routing
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
