import Ember from 'ember';

export default Ember.Route.extend({
    actions: {
        joinTeam() {
            let accessCode = this.controller.get('accessCode');
            this.transitionTo('app.teams.access', accessCode);
        }
    }
});
