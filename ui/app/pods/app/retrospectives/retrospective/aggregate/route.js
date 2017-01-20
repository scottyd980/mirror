import Ember from 'ember';
import config from '../../../../../config/environment';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    model() {
        return RSVP.hash({
            parent: this.modelFor('app.retrospectives.retrospective'),
            scores: this.modelFor('app.retrospectives.retrospective').retrospective.get('scores')
        });
    }
});
