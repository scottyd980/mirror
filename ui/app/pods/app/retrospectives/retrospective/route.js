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
    redirect(model) {
        var state = model.retrospective.get('state');
        var dynamicRouteSegment = config.retrospective.sticky_notes.states[state];
        this.transitionTo('app.retrospectives.retrospective.' + dynamicRouteSegment);
    },
    setupController(controller, model) {
        this._super(...arguments);

        controller.set('hasRetroInProgress', false);
        controller.set('isRetroStartModalShowing', false);
        controller.set('isActionModalShowing', false);
        controller.set('actionMessage', '');

        this.get('retrospectiveService').join_retrospective_channel(model.retrospective.get('id'));
    },
    deactivate() {
        this.get('retrospectiveService').leave_retrospective_channel(this.get('currentModel').retrospective.get('id'));
    },
    actions: {
        changeRetrospectiveState(currentStateSegment, direction) {
            var retrospective = this.get('currentModel').retrospective;

            //TODO: Need to account for games here
            const currentState = config.retrospective.sticky_notes.states.indexOf(currentStateSegment);

            retrospective.set('state', (currentState + direction));
            retrospective.save();
        },
        moveFeedback(id, state) {
            this.store.findRecord('feedback', id).then((fb) => {
                fb.set('state', state);
                fb.save();
            });
        },
        cancelRetrospective() {
            let _this = this;
            let retrospective = this.get('currentModel').retrospective;
            retrospective.set('cancelled', true);
            retrospective.save().then(() => {
                _this.transitionTo('app.teams.team.dashboard.retrospectives', this.get('currentModel').team).then(() => {
                    _this.get('notificationCenter').success({
                        title: config.SUCCESS_MESSAGES.generic,
                        message: "The retrospective was successfully cancelled."
                    });
                });
                
            }).catch(() => {
                _this.get('notificationCenter').error({
                    title: config.ERROR_MESSAGES.generic,
                    message: "We experienced an unexpected error. Please try again."
                });
            });
        },
        openActionModal(feedback) {
            const _this = this;
            let actionMessage = '';

            feedback.get('action').then((action) => {
                if(action) {
                    actionMessage = action.get('message');
                }

                _this.controller.set('activeFeedback', feedback);
                _this.controller.set('actionMessage', actionMessage);
                _this.controller.set('isActionModalShowing', true);
            });
        },
        closeActionModal() {
            const _this = this;
            _this.controller.set('isActionModalShowing', false);
            _this.controller.set('activeFeedback', null);
            _this.controller.set('actionMessage', '');
        },
        submitActionItem() {
            const _this = this;
            const feedback = _this.controller.get('activeFeedback');
            const message = _this.controller.get('actionMessage');

            feedback.get('action').then((action) => {
                if(message.trim() !== "" && action) {
                    action.set('message', message);
                    action.save();
                } else if(message.trim() !== "") {
                    _this.store.createRecord('action', {
                        message: message,
                        feedback: feedback
                    }).save();
                } else if(message.trim() === "" && action) {
                    action.destroyRecord();
                }
                
                _this.send('closeActionModal');
            });
        }
    }
});
