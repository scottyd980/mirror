import Route from '@ember/routing/route';
import { hash } from 'rsvp';

export default Route.extend({
  model() {
    // Need to reload scores in case someone left the retrospective but isn't listening for changes.
    const scores = this.modelFor('app.retrospectives.retrospective').retrospective.hasMany('scores');
    scores.reload();

    return hash({
      parent: this.modelFor('app.retrospectives.retrospective'),
      scores: this.modelFor('app.retrospectives.retrospective').retrospective.get('scores')
    });
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