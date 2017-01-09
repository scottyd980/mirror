import Ember from 'ember';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        return this.modelFor('app.retrospectives.retrospective')
    },
    actions: {
        submitScore() {
            let score = this.store.createRecord('score');

            score.set('score', 1);
            score.set('retrospective', this.currentModel.retrospective);
            score.set('user', this.get('session').get('currentUser'));

            score.save();
        }
    }
});
