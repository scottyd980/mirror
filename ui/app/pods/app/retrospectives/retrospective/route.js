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

        var currentUser = _this.get('session').get('currentUser');

        let isModerator = retrospective.then((retrospective) => {
            return currentUser.get('id') === retrospective.get('moderator.id');
        });

        return RSVP.hash({
            retrospective: retrospective,
            team: team,
            team_members: team_members,
            currentUser: currentUser,
            isModerator: isModerator
        });
    },
    redirect(model, transition) {
        var state = model.retrospective.get('state');
        var dynamicRouteSegment = config.retrospective.sticky_notes.states[state];
        this.transitionTo('app.retrospectives.retrospective.' + dynamicRouteSegment);
    },
    setupController(controller, model) {
        this._super(...arguments);

        controller.set('hasRetroInProgress', false);
        controller.set('isRetroStartModalShowing', false);

        var retro = this.get('retrospectiveService').join_retrospective_channel(model.retrospective.get('id'));
    },
    actions: {
        changeRetrospectiveState(state) {
            var retrospective = this.get('currentModel').retrospective;
            retrospective.set('state', state);
            retrospective.save();
        },
        moveFeedback(id, state) {
            this.store.findRecord('feedback', id).then((fb) => {
                fb.set('state', state);
                fb.save();
            });
        },
        cancelRetrospective() {
            var retrospective = this.get('currentModel').retrospective;
            retrospective.destroyRecord();
        }
    }
});
