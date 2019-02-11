import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';
import ENV from 'mirror/config/environment';

export default Route.extend({
  session: service(),
  model() {
    const parent = this.modelFor('app.retrospectives.retrospective')

    return this.get('store').findRecord('retrospective', parent.retrospective.get('id'))
    .then((retrospective) => {
      return Promise.all([retrospective.get('team'), retrospective.get('scores'), retrospective.get('scoreSubmissions')]).then((results) => {
        const team = results[0],
              scores = results[1],
              scoreSubmissions = results[2];
        
        return team.get('members').then((team_members) => {
          return hash({
            retrospective,
            team,
            team_members,
            scores,
            scoreSubmissions
          });
        }).catch(() => { throw ENV.ERROR_CODES.not_found});
      },
      () => { throw ENV.ERROR_CODES.not_found; });
    }).catch(() => { throw ENV.ERROR_CODES.not_found });
  },
  setupController(controller, model) {
    this._super(...arguments);

    const scores = model.scores;

    controller.set('submitted', false);
    controller.set('score', null);

    const userScore = scores.filter((score) => {
      return parseInt(score.get('user.id')) === parseInt(this.get('session').get('currentUser.id'));
    });

    if (typeof userScore !== "undefined" && userScore.length > 0) {
      this._markScoreSubmitted(userScore[0].get('score'));
    }
  },
  _markScoreSubmitted(score) {
    if (score) {
      this.controller.set('score', score);
    }
    this.controller.set('submitted', true);
  }
});
