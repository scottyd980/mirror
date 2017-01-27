import Ember from 'ember';
import config from '../../../../../config/environment';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        return RSVP.hash({
            parent: this.modelFor('app.retrospectives.retrospective'),
            scores: this.modelFor('app.retrospectives.retrospective').retrospective.get('scores')
        });
    },
    setupController(controller, model) {
        this._super(...arguments);

        let scores = model.scores;

        controller.set('submitted', false);

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
    actions: {
        submitScore() {
            let _this = this;
            let score = this.store.createRecord('score');

            let sprintScore = $('input[name="sprintScore"]:checked').val();

            if(typeof sprintScore !== "undefined") {

                score.set('score', sprintScore);
                score.set('retrospective', this.currentModel.parent.retrospective);
                score.set('user', this.get('session').get('currentUser'));

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
        }
    }
});
