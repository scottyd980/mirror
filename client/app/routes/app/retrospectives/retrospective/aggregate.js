import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import ENV from 'mirror/config/environment';

export default Route.extend({
  model() {
    const parent = this.modelFor('app.retrospectives.retrospective')

    return this.get('store').findRecord('retrospective', parent.retrospective.get('id'))
    .then((retrospective) => {
      return Promise.all([retrospective.get('team'), retrospective.get('scores')]).then((results) => {
        const team = results[0],
              scores = results[1];
        
        return team.get('members').then((team_members) => {
          return hash({
            retrospective,
            team,
            team_members,
            scores
          });
        }).catch(() => { throw ENV.ERROR_CODES.not_found});
      },
      () => { throw ENV.ERROR_CODES.not_found; });
    }).catch(() => { throw ENV.ERROR_CODES.not_found });
  },
  setupController(controller, model) {
    this._super(...arguments);

    const scores = model.scores.sortBy('score');

    const average = scores.reduce((total, score) => {
      return total + score.get('score');
    }, 0) / scores.length;

    controller.set('low_score', (typeof scores[0] !== "undefined" ? scores[0] : { score: "N/A" }));
    controller.set('high_score', (typeof scores[scores.length - 1] !== "undefined" ? scores[scores.length - 1] : { score: "N/A" }));
    controller.set('average_score', average || "N/A");
  }
});
