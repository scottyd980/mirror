import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service(),
    model() {
       return RSVP.hash({
           organizations: this.get('session.currentUser').get('organizations').sortBy('id')
       });
    },
    actions: {
        viewOrganization(organization) {
            this.transitionTo('app.organizations.organization', organization);
        }
    }
});
