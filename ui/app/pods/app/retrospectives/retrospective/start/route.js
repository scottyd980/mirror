import Ember from 'ember';

export default Ember.Route.extend({
    model() {
        return this.modelFor('app.retrospectives.retrospective')
    },
    actions: {
        startRetrospective() {
            console.log('test');
        }
    }
});
