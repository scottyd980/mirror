import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        var _this = this;
        return RSVP.hash({
            organization: this.modelFor('app.organizations.organization'),
            currentUser: _this.get('session').get('currentUser'),
            teams: this.modelFor('app.organizations.organization').get('teams')
        });
    },
    setupController(controller, models) {
        var _this = this;
        _this._super(controller, models);

        controller.set('isAdmin', models.organization.get('admins').includes(models.currentUser));
    },
    toggleLoadingScreen(message) {
        this.controller.set('loadingMessage', message);
        this.controller.toggleProperty('currentlyLoading');
    },
    actions: {
        viewTeam(team) {
            this.transitionTo('app.teams.team.dashboard.retrospectives', team);
        },
        toggleLoadingScreen(message) {
            this.toggleLoadingScreen(message);
        },
        removeTeam(team) {
            this.toggleLoadingScreen("Removing Team...");
            team.set('organization', null);
            team.save().then(() => {
                //this.send('invalidateApplicationModel');
                this.toggleLoadingScreen();
            }).catch((error) => {
                // TODO: Handle error
                this.toggleLoadingScreen();
            }); 
        }
    }
});
