import Ember from 'ember';

export default Ember.Controller.extend({
    initialState: null,
    retrospectiveStateChanged: Ember.observer('model.retrospective.state', function() {
        var state = this.get('model.retrospective.state');
        
        if(this.get('initialState') === null) {
            this.set('initialState', state);
        } else {
            this.transitionToRoute('app.retrospectives.retrospective.score');
        }
    })
});
