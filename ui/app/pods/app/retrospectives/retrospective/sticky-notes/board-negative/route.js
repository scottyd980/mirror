import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        // Need to reload feedbacks in case someone left the retrospective but isn't listening for changes.
        const feedbacks = this.modelFor('app.retrospectives.retrospective').retrospective.hasMany('feedbacks');
        feedbacks.reload();

        return RSVP.hash({
            parent: this.modelFor('app.retrospectives.retrospective'),
            feedback: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedbacks')
        });
    },
    setupController(controller, model) {
        this._super(...arguments);

        let _this = this,
            feedback = model.feedback;

        let negativeFeedback = _this._shuffle(feedback.filter((fb) => {
            return fb.get('category') === "negative";
        }));

        controller.set('negative_feedback', negativeFeedback);
    },
    _shuffle(array) {
        var currentIndex = array.length, temporaryValue, randomIndex;
        while (0 !== currentIndex) {
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex -= 1;
            
            temporaryValue = array[currentIndex];
            array[currentIndex] = array[randomIndex];
            array[randomIndex] = temporaryValue;
        }

        return array;
    }
});
