import Ember from 'ember';
import config from '../../../../../config/environment';

export default Ember.Route.extend({
    session: Ember.inject.service('session'),
    model() {
        return this.modelFor('app.retrospectives.retrospective')
    },
    actions: {
        submitScore() {
            let score = this.store.createRecord('score');

            let sprintScore = $('input[name="sprintScore"]:checked').val();

            if(typeof sprintScore !== "undefined") {

                score.set('score', sprintScore);
                score.set('retrospective', this.currentModel.retrospective);
                score.set('user', this.get('session').get('currentUser'));

                score.save();
            
            } else {
                this.get('notificationCenter').error({
                    title: config.ERROR_MESSAGES.process,
                    message: "You must select a score before submitting. Please try again."
                });
            }
        }
    }
});
