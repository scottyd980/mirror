import Ember from 'ember';

export default Ember.Route.extend({
    model() {
        return this.modelFor('app.retrospectives.retrospective')
    },
    actions: {
        startRetrospective() {
            var retrospective = this.get('currentModel').retrospective;
            retrospective.set('state', 1);
            retrospective.save();

        }
    }
});
