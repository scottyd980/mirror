import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';

export default Route.extend({
  session: service(),
  model() {
    return hash({
      parent: this.modelFor('app.retrospectives.retrospective'),
      scores: this.modelFor('app.retrospectives.retrospective').retrospective.get('scores'),
      scoreSubmissions: this.modelFor('app.retrospectives.retrospective').retrospective.get('scoreSubmissions'),
    });
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
