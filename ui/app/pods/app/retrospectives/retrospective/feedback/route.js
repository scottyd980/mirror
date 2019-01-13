import Ember from 'ember';
import config from '../../../../../config/environment';
import RSVP from 'rsvp';
import fetch from 'ember-network/fetch';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    uuid: Ember.inject.service('uuid'),
    model() {
        return RSVP.hash({
            parent: this.modelFor('app.retrospectives.retrospective'),
            feedback: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedbacks'),
            feedbackSubmissions: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedbackSubmissions'),
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

    submitFeedback(uuid) {
        let _this = this;
        var feedbackToSubmit = [];

        _this.currentModel.gameInput.forEach((feedback) => {
            if(feedback.value.trim() !== "") {
                let fb = _this.store.createRecord('feedback', {
                    category: feedback.type,
                    message: feedback.value,
                    user: _this.get('session').get('currentUser'),
                    retrospective: _this.currentModel.parent.retrospective,
                    uuid: uuid
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
    },
    
    actions: {
        submitFeedback() {
            let _this = this;
            const uuid = this.get('uuid').get('hash');
            if(uuid) {
                _this.submitFeedback(uuid);
            } else {
                fetch(`${config.DS.host}/${config.DS.namespace}/uuid`, {
                    type: 'GET',
                    headers: {
                        'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`
                    }
                }).then((response) => {
                    if(response.status === 200) {
                        response.json().then((uuid) => {
                            _this.get('uuid').set('hash', uuid.hash);
                            _this.submitFeedback(uuid.hash);
                        });
                    } else {
                        _this.get('notificationCenter').error({
                            title: config.ERROR_MESSAGES.process,
                            message: "There was a problem submitting your feedback. Please try again."
                        });
                    }
                });
            }
        }
    }
});
