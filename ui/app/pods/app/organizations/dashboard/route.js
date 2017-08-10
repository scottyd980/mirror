import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service(),
    model() {
       return RSVP.hash({
           organizations: this.get('session.currentUser').get('organizations').sortBy('id')
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
        viewOrganization(organization) {
            this.transitionTo('app.organizations.organization.dashboard', organization);
        },
        deleteOrganization(organization) {
            this.toggleLoadingScreen("Deleting Organization...");
            organization.destroyRecord().then(() => {
                this.toggleLoadingScreen();
                this.send('invalidateApplicationModel');
            });
        },

    }
});
