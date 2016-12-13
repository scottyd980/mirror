import Ember from 'ember';
import RSVP from 'rsvp';
import config from '../../../../config/environment';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    socket: Ember.inject.service('socket-service'),
    retrospectiveService: Ember.inject.service('retrospective-service'),
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

        return RSVP.hash({
            retrospective: retrospective,
            team: team,
            team_members: team_members,
            currentUser: _this.get('session').get('currentUser')
        });
    },
    setupController(controller, model) {
        this._super(...arguments);

        controller.set('hasRetroInProgress', false);
        controller.set('isRetroStartModalShowing', false);

        var retro = this.get('retrospectiveService').join_retrospective_channel(model.retrospective.get('id'));

        //controller.set('retrospective', retro);
    },
});
