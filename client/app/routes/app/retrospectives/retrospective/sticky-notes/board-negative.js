import Route from '@ember/routing/route';
import { hash } from 'rsvp';

export default Route.extend({
  model() {
    // Need to reload feedbacks in case someone left the retrospective but isn't listening for changes.
    const feedbacks = this.modelFor('app.retrospectives.retrospective').retrospective.hasMany('feedbacks');
    feedbacks.reload();

    return hash({
      parent: this.modelFor('app.retrospectives.retrospective'),
      feedback: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedbacks')
    });
  },
  setupController(controller, model) {
    this._super(...arguments);

    // TODO: Need to make only a single item show up on the initial load
    const feedback = model.feedback;

    const negativeFeedback = this._shuffle(feedback.filter((fb) => {
      return fb.get('category') === "negative";
    }));

    controller.set('current_feedback_count', negativeFeedback.findIndex(fb => fb.get('state') === 1) + 1);
    controller.set('negative_feedback', negativeFeedback);
  },
  _shuffle(array) {
    let currentIndex = array.length, temporaryValue, randomIndex;
    while (0 !== currentIndex) {
      randomIndex = Math.floor(Math.random() * currentIndex);
      currentIndex -= 1;

      temporaryValue = array[currentIndex];
      array[currentIndex] = array[randomIndex];
      array[randomIndex] = temporaryValue;
    }

    return array;
  }
});