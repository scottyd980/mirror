import Ember from 'ember';
import config from '../../../../config/environment';

export default Ember.Controller.extend({
    initialState: null,
    retrospectiveStateChanged: Ember.observer('model.retrospective.state', function() {
        let state = this.get('model.retrospective.state');
        
        //Will eventually want to make game type dynamic as well
        var dynamicRouteSegment = config.retrospective.sticky_notes.states[state];
        this.transitionToRoute('app.retrospectives.retrospective.' + dynamicRouteSegment, this.get('model'));
    }),
    retrospectiveCancelled: Ember.observer('model.retrospective.cancelled', function() {
        let cancelled = this.get('model.retrospective.cancelled'),
            team = this.get('model.retrospective.team');
        
        if(cancelled) {
            this.transitionToRoute('app.teams.team.dashboard.retrospectives', team);
        }
    })
});
