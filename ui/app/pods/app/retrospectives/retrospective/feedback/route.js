import Ember from 'ember';
import config from '../../../../../config/environment';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        return RSVP.hash({
            parent: this.modelFor('app.retrospectives.retrospective'),
            feedback: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedback')
        });
    },
    setupController(controller, model) {
        this._super(...arguments);

        let feedback = model.feedback;

        let userFeedback = feedback.filter((fb) => {
            return parseInt(fb.get('user.id')) === parseInt(this.get('session').get('currentUser.id'));
        });

        if(typeof userFeedback !== "undefined" && userFeedback.length > 0) {
            this._markFeedbackSubmitted(userScore[0].get('score'));
        }
    },
    _markFeedbackSubmitted(score) {
        if(score) {
            this.controller.set('score', score);
        }
        this.controller.set('submitted', true);
        $('#score-submit').html("<i class='fa fa-fw fa-check'></i> Score Submitted");
        $('#score-submit').prop('disabled', true);
    },
    actions: {
        submitFeedback() {
            let _this = this;

            if(typeof sprintScore !== "undefined") {

                
            
            } else {
                this.get('notificationCenter').error({
                    title: config.ERROR_MESSAGES.process,
                    message: "You must select a score before submitting. Please try again."
                });
            }
        }
    }
});
