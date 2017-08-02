import Ember from 'ember';
import RSVP from 'rsvp';
import config from '../../../config/environment';

const { inject } = Ember;

export default Ember.Route.extend({
    session: inject.service(),
    model() {
        let current_user = this.get('session.currentUser');

        return RSVP.hash({
            teams: current_user.get('teams').sortBy('id'),
            organizations: current_user.get('organizations').sortBy('id'),
            /* TODO: May want to look at getting this the ember way so data works correctly. */
            recent_retrospectives: fetch(`${config.DS.host}/${config.DS.namespace}/retrospectives/recent`, {
                type: 'GET',
                headers: {
                    'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`
                }
            }).then((raw) => {
                return raw.json().then(data => data.data);
            })
        });
    }
});
