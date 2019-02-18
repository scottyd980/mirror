import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';
import ENV from 'mirror/config/environment';

export default Route.extend({
  retroSvc: service('retrospective'),
  model() {
    const parent = this.modelFor('app.retrospectives.retrospective')

    return this.get('store').findRecord('retrospective', parent.retrospective.get('id'))
    .then((retrospective) => {
      return Promise.all([retrospective.get('team'), retrospective.get('scores'), retrospective.get('feedbacks')]).then((results) => {
        const team = results[0],
              scores = results[1],
              feedback = results[2];
        
        return team.get('members').then((team_members) => {
          return hash({
            retrospective,
            team,
            team_members,
            scores,
            feedback
          });
        }).catch(() => { throw ENV.ERROR_CODES.not_found});
      },
      () => { throw ENV.ERROR_CODES.not_found; });
    }).catch(() => { throw ENV.ERROR_CODES.not_found });
  },
  setupController(controller, model) {
    this._super(...arguments);

    const scores = model.scores.sortBy('score');

    const average = +parseFloat(scores.reduce((total, score) => {
      return total + score.get('score');
    }, 0) / scores.length).toFixed(1);

    controller.set('low_score', (typeof scores[0] !== "undefined" ? scores[0] : { score: "N/A" }));
    controller.set('high_score', (typeof scores[scores.length - 1] !== "undefined" ? scores[scores.length - 1] : { score: "N/A" }));
    controller.set('average_score', average || "N/A");
  }
});
