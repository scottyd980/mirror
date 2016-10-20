import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
  model() {
    return RSVP.hash({
      team: this.modelFor('app.teams.team')
    });
  }
});
