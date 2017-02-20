import Ember from 'ember';
import config from '../../../../config/environment';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model(params) {
        var _this = this;

        let retrospective = _this.get('store').findRecord('retrospective', params.id).catch(() => {
            throw config.ERROR_CODES.not_found;
        });

        let team = retrospective.then((retrospective) => {
            return retrospective.get('team');
        }).catch(() => {
            throw config.ERROR_CODES.not_found;
        });

        let team_members = team.then((team) => {
            return team.get('members');
        }).catch(() => {
            throw config.ERROR_CODES.not_found;
        });

        let scores = retrospective.then((retrospective) => {
            return retrospective.get('scores');
        }).catch(() => {
            throw config.ERROR_CODES.not_found;
        });

        let feedback = retrospective.then((retrospective) => {
            return retrospective.get('feedbacks');
        }).catch(() => {
            throw config.ERROR_CODES.not_found;
        });

        var currentUser = _this.get('session').get('currentUser');

        return RSVP.hash({
            retrospective: retrospective,
            team: team,
            team_members: team_members,
            currentUser: currentUser,
            scores: scores,
            feedback: feedback
        });
    },
    setupController(controller, model) {
        this._super(...arguments);

        let scores = model.scores.sortBy('score');

        let average = scores.reduce((total, score) => {
            return total + score.get('score');
        }, 0) / scores.length;

        controller.set('low_score', (typeof scores[0] !== "undefined" ? scores[0] : {score: "N/A"}));
        controller.set('high_score', (typeof scores[scores.length - 1] !== "undefined" ? scores[0] : {score: "N/A"}));
        controller.set('average_score', average || "N/A");
    }
});
