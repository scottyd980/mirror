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
        var _this = this;

        this._super(...arguments);

        let feedback = model.feedback;
        
        model.gameInput.forEach((feedback) => {
            feedback.value = "";
        });

        model.gameInput.forEach((feedbackType) => {
            controller.set('feedback_' + feedbackType.type, null);
        });

        let userFeedback = feedback.filter((fb) => {
            return parseInt(fb.get('user.id')) === parseInt(this.get('session').get('currentUser.id'));
        });

        if(typeof userFeedback !== "undefined" && userFeedback.length > 0) {
            this._markFeedbackSubmitted(userFeedback);
        }
    },
    _markFeedbackSubmitted(feedbacks) {
        if(feedbacks) {
            this.currentModel.gameInput.forEach((input) => {
                input.value = feedbacks.find((feedback) => {
                    return feedback.get('type') === input.type;
                }).get('message');
            });
        }
        this.controller.set('submitted', true);
        $('#feedback-submit').html("<i class='fa fa-fw fa-check'></i> Feedback Submitted");
        $('#feedback-submit').prop('disabled', true);
    },
    
    actions: {
        submitFeedback() {
            let _this = this;

            var feedbacks = $('.feedbacks [id$=-textarea]');

            var feedbackToSubmit = [];

            this.currentModel.gameInput.forEach((feedback) => {
                if(feedback.value.trim() !== "") {
                    let fb = _this.store.createRecord('feedback', {
                        type: feedback.type,
                        message: feedback.value,
                        user: _this.get('session').get('currentUser'),
                        retrospective: _this.currentModel.parent.retrospective
                    });

                    feedbackToSubmit.push(fb.save());
                }
            });

            RSVP.Promise.all(
                feedbackToSubmit
            ).then(function(submitted) {
                _this._markFeedbackSubmitted();
            }).catch(function(error) {
                _this.get('notificationCenter').error({
                    title: config.ERROR_MESSAGES.process,
                    message: "There was a problem submitting your feedback. Please try again."
                });
            });
        }
    }
});
