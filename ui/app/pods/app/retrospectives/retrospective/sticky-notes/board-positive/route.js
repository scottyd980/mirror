import Ember from 'ember';
import config from '../../../../../../config/environment';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        return RSVP.hash({
            parent: this.modelFor('app.retrospectives.retrospective'),
            feedback: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedbacks')
        });
    },
    setupController(controller, model) {
        this._super(...arguments);

        let _this = this,
            feedback = model.feedback;

        let positiveFeedback = feedback.filter((fb) => {
            return fb.get('type') === "positiveFeedback";
        });

        controller.set('negative_feedback', positiveFeedback);
    },
    
    actions: {
        
    }
});
