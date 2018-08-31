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
            scores: this.modelFor('app.retrospectives.retrospective').retrospective.get('scores'),
            scoreSubmissions: this.modelFor('app.retrospectives.retrospective').retrospective.get('scoreSubmissions'),
        });
    },
    setupController(controller, model) {
        this._super(...arguments);

        let scores = model.scores;

        controller.set('submitted', false);
        controller.set('score', null);
        
        let userScore = scores.filter((score) => {
            return parseInt(score.get('user.id')) === parseInt(this.get('session').get('currentUser.id'));
        });

        if(typeof userScore !== "undefined" && userScore.length > 0) {
            this._markScoreSubmitted(userScore[0].get('score'));
        }
    },
    _markScoreSubmitted(score) {
        if(score) {
            this.controller.set('score', score);
        }
        this.controller.set('submitted', true);
    },

    submitScore(uuid) {
        let _this = this;
        let score = this.store.createRecord('score');

        let sprintScore = $('input[name="sprintScore"]:checked').val();

        if(typeof sprintScore !== "undefined") {

            score.set('score', sprintScore);
            score.set('retrospective', this.currentModel.parent.retrospective);
            score.set('user', this.get('session').get('currentUser'));
            score.set('uuid', uuid);

            $('#score-submit').html("<i class='fa fa-fw fa-refresh fa-spin'></i> Submitting Score...");
            $('#score-submit').prop('disabled', true);

            score.save().then(function() {
                _this._markScoreSubmitted();
            });
        
        } else {
            this.get('notificationCenter').error({
                title: config.ERROR_MESSAGES.process,
                message: "You must select a score before submitting. Please try again."
            });
        }
    },

    actions: {
        submitScore() {
            let _this = this;
            const uuid = this.get('uuid').get('hash');
            if(uuid) {
                _this.submitScore(uuid);
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
                            _this.submitScore(uuid.hash);
                        });
                    } else {
                        _this.get('notificationCenter').error({
                            title: config.ERROR_MESSAGES.process,
                            message: "There was a problem submitting your score. Please try again."
                        });
                    }
                });
            }
        }
    }
});
