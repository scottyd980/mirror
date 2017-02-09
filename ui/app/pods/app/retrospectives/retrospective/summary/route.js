import Ember from 'ember';
import config from '../../../../../config/environment';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    model() {
        return RSVP.hash({
            parent: this.modelFor('app.retrospectives.retrospective'),
            scores: this.modelFor('app.retrospectives.retrospective').retrospective.get('scores')
        });
    },
    setupController(controller, model) {
        this._super(...arguments);

        let scores = model.scores.sortBy('score');

        let average = scores.reduce((total, score) => {
            return total + score.get('score');
        }, 0) / scores.length;

        controller.set('low_score', scores[0]);
        controller.set('high_score', scores[scores.length - 1]);
        controller.set('average_score', average);
    }
});
