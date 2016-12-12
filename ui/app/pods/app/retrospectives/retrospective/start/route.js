import Ember from 'ember';

export default Ember.Route.extend({
    model() {
        return this.modelFor('app.retrospectives.retrospective')
    },
    setupController(controller, model) {
        this._super(...arguments);
        console.log(model);
    }
});
