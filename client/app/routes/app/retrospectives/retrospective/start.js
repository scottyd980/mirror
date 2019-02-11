import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import ENV from 'mirror/config/environment';

export default Route.extend({
  model() {
    const parent = this.modelFor('app.retrospectives.retrospective')

    return this.get('store').findRecord('retrospective', parent.retrospective.get('id'))
    .then((retrospective) => {
      return retrospective.get('team').then((team) => {
        return team.get('members').then((team_members) => {
          return hash({
            retrospective,
            team,
            team_members
          });
        }).catch(() => { throw ENV.ERROR_CODES.not_found});
      }).catch(() => { throw ENV.ERROR_CODES.not_found});
    }).catch(() => { throw ENV.ERROR_CODES.not_found});
  }
});
