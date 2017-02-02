import Ember from 'ember';
import config from '../../../../config/environment';

export default Ember.Controller.extend({
    initialState: null,
    retrospectiveStateChanged: Ember.observer('model.retrospective.state', function() {
        var state = this.get('model.retrospective.state');
        
        // if(this.get('initialState') === null) {
        //     this.set('initialState', state);
        // } else {
            //Will eventually want to make game type dynamic as well
            var dynamicRouteSegment = config.retrospective.sticky_notes.states[state];
            this.transitionToRoute('app.retrospectives.retrospective.' + dynamicRouteSegment, this.get('model'));
        // }
    })
});
