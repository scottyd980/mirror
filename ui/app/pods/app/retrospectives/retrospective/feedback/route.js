import Ember from 'ember';
import config from '../../../../../config/environment';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        return RSVP.hash({
            parent: this.modelFor('app.retrospectives.retrospective'),
            feedback: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedbacks'),
            gameInput: config.retrospective["sticky_notes"].feedback
        });
    },
    setupController(controller, model) {
        let _this = this,
            feedback = model.feedback;

        _this._super(...arguments);

        controller.set('submitted', false);
        
        model.gameInput.forEach((feedback) => {
            feedback.value = "";
        });

        let userFeedback = feedback.filter((fb) => {
            return parseInt(fb.get('user.id')) === parseInt(_this.get('session').get('currentUser.id'));
        });

        if(typeof userFeedback !== "undefined" && userFeedback.length > 0) {
            _this._markFeedbackSubmitted(userFeedback);
        }
    },
    _markFeedbackSubmitted(feedbacks) {
        let _this = this;
        if(feedbacks) {
            _this.currentModel.gameInput.forEach((input) => {
                input.value = feedbacks.find((feedback) => {
                    return feedback.get('category') === input.type;
                }).get('message');
            });
        }
        _this.controller.set('submitted', true);
    },
    
    actions: {
        submitFeedback() {
            let _this = this;

            var feedbackToSubmit = [];

            _this.currentModel.gameInput.forEach((feedback) => {
                if(feedback.value.trim() !== "") {
                    let fb = _this.store.createRecord('feedback', {
                        category: feedback.type,
                        message: feedback.value,
                        user: _this.get('session').get('currentUser'),
                        retrospective: _this.currentModel.parent.retrospective
                    });

                    feedbackToSubmit.push(fb.save());
                }
            });

            RSVP.Promise.all(
                feedbackToSubmit
            ).then(function() {
                _this._markFeedbackSubmitted();
            }).catch(function() {
                _this.get('notificationCenter').error({
                    title: config.ERROR_MESSAGES.process,
                    message: "There was a problem submitting your feedback. Please try again."
                });
            });
        }
    }
});
