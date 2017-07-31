import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    model() {
        var _this = this;
        return RSVP.hash({
            team: _this.modelFor('app.teams.team')
        });
    },
    toggleLoadingScreen(message) {
        this.controller.set('loadingMessage', message);
        this.controller.toggleProperty('currentlyLoading');
    },
    actions: {
        toggleLoadingScreen(message) {
            this.toggleLoadingScreen(message);
        },
        deleteTeam(team) {
            this.toggleLoadingScreen("Deleting Team...");
            team.destroyRecord().then(() => {
                this.toggleLoadingScreen();
                this.transitionTo('app.dashboard');
            });
        }
    }
});
