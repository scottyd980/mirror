import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    model() {
        return RSVP.hash({
            parent: this.modelFor('app.retrospectives.retrospective'),
            scores: this.modelFor('app.retrospectives.retrospective').retrospective.get('scores'),
            feedback: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedbacks')
        });
    },
    setupController(controller, model) {
        this._super(...arguments);

        let scores = model.scores.sortBy('score');

        let average = scores.reduce((total, score) => {
            return total + score.get('score');
        }, 0) / scores.length;

        controller.set('low_score', (typeof scores[0] !== "undefined" ? scores[0] : {score: "N/A"}));
        controller.set('high_score', (typeof scores[scores.length - 1] !== "undefined" ? scores[scores.length - 1] : {score: "N/A"}));
        controller.set('average_score', average || "N/A");
    }
});
