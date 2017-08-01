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
        updateTeam(team) {
            this.toggleLoadingScreen("Updating Team Preferences...");
            let isAnonymous = $(`input[name="is-anon-${team.get('id')}"]:checked`).val() === "true" ? true : false;
            team.set('isAnonymous', isAnonymous);
            team.save().then(() => {
                this.toggleLoadingScreen();
            });
        },
        deleteTeam(team) {
            this.toggleLoadingScreen("Deleting Team...");
            team.destroyRecord().then(() => {
                this.toggleLoadingScreen();
                this.send('invalidateApplicationModel');
                this.transitionTo('app');
            });
        }
    }
});
