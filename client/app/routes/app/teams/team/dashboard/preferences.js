import Route from '@ember/routing/route';
import { hash } from 'rsvp';

export default Route.extend({
  model() {
    return hash({
      team: this.modelFor('app.teams.team')
    });
  },
  setupController(controller) {
    this._super(...arguments);
    controller.set('currentlyLoading', false);
    controller.set('loadingMessage', null);
  }
});