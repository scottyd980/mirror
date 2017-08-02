import Ember from 'ember';
import RSVP from 'rsvp';

const { inject } = Ember;

export default Ember.Route.extend({
    session: inject.service(),
    model() {
        let current_user = this.get('session.currentUser');

         return RSVP.hash({
             teams: current_user.get('teams').sortBy('id'),
             organizations: current_user.get('organizations').sortBy('id')
         });
    }
});
