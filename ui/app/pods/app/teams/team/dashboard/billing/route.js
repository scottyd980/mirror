import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        var _this = this;
        return RSVP.hash({
            team: _this.modelFor('app.teams.team'),
            user_organizations: this.get('session.currentUser').get('organizations')
        });
    }
});
