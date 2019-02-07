import Controller from '@ember/controller';
import fetch from 'fetch';
import ENV from 'mirror/config/environment';
import { inject as service } from '@ember/service';

export default Controller.extend({
  session: service(),
  retroSvc: service('retrospective'),
  retrospective: null,
  hasRetroInProgress: false,
  isRetroStartModalShowing: false,
  isBillingModalShowing: false,
  gameToStart: false,
  isAdmin: false,
  currentlyLoading: false,
  toggleLoadingScreen(message) {
    this.set('loadingMessage', message);
    this.toggleProperty('currentlyLoading');
  },
  actions: {
    enterRetrospectiveType(game_to_start) {
      this.set('isRetroStartModalShowing', true);
      this.set('gameToStart', game_to_start);
    },
    cancelEnterRetrospectiveType() {
      this.set('isRetroStartModalShowing', false);
    },
    toggleBillingModal() {
      this.toggleProperty('isBillingModalShowing');
    },
    startRetrospective(/* TODO: game */) {
      let retrospective = this.store.createRecord('retrospective', {
        name: 'Sprint ' + this.model.nextSprint,
        team: this.model.team,
        moderator: this.get('session.currentUser'),
        isAnonymous: this.model.team.get('isAnonymous'),
        game: ENV.retrospective[this.get('gameToStart')].type_id,
        participants: []
      });
  
      this.send('cancelEnterRetrospectiveType');
      this.toggleLoadingScreen('Setting up retrospective...');
  
      this.get('retroSvc').start(retrospective).then((result) => {
        this.send('joinRetrospective', result.id);
        this.toggleLoadingScreen();
      }).catch((error) => {
        this.toggleLoadingScreen();
        if (error.errors[0].code === 403) {
          this.send('cancelEnterRetrospectiveType');
          this.send('toggleBillingModal');
        } else if (error.errors[0].code === 409) {
          this.get('notifications').error({
            title: ENV.ERROR_MESSAGES.retrospective_in_progress,
            message: "There is currently a retrospective in progress. Please join the retrospective already in progress or wait until it is completed or cancelled before trying to start another one. If the retrospective in progress was started in error, an admin can cancel it from the history page."
          });
        } else {
          this.get('notifications').error({
            title: ENV.ERROR_MESSAGES.generic,
            message: "We experienced an unexpected error trying to start the retrospective. Please try again."
          });
        }
      });
    },
    joinRetrospective(retrospective_id) {
      return fetch(`${ENV.DS.host}/${ENV.DS.namespace}/retrospective_participants`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
          'Content-Type': 'application/vnd.api+json'
        },
        body: JSON.stringify({
          "retrospective_id": retrospective_id
        })
      }).then((response) => {
        if (response.status === ENV.STATUS_CODES.created || response.status === ENV.STATUS_CODES.ok) {
          response.json().then((resp) => {
            // Always direct to start, the retrospective controller will handle additional re-routing
            this.transitionToRoute('app.retrospectives.retrospective.start', resp.data.attributes["retrospective-id"]);
          });
        } else {
          throw new Error('Unexpected response from server');
        }
      }).catch(() => {
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.generic,
          message: "We experienced an unexpected error trying to join the retrospective. Please try again."
        });
      });
    }
  }
});