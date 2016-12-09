import Ember from 'ember';
import RSVP from 'rsvp';
//import config from '../../../../../../config/environment';

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

    console.log(retro);

    controller.set('retrospective', retro);

    //let chan = this.get('socket').joinChannel(`team:${model.team.get('id')}`);

    //controller.set('channel', chan);
    //chan.push('inProgress');

    // chan.on('inProgress', () => {
    //   controller.set('hasRetroInProgress', true);
    // });

    // chan.push('check_retrospective_in_progress', {});
    // chan.on('retrospective_in_progress', (resp) => {
    //   this.setRetrospectiveInProgress(resp.retrospective_in_progress)
    // });
    // chan.on('joined_retrospective', (resp) => {
    //
    //   console.log(resp);
    //   // Need to handle current user / not current user
    //   this.moveToRetrospectiveInProgress(resp.retrospective);
    // });
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
    joinRetrospectiveInProgress() {
      this.get('retrospectiveService').sendMessage('join_retrospective_in_progress', {});
    }
  }
});
