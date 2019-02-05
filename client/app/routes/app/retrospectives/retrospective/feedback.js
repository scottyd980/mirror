import Route from '@ember/routing/route';
import ENV from 'mirror/config/environment';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';
import { set } from '@ember/object';

export default Route.extend({
  session: service(),
  model() {
    return hash({
      parent: this.modelFor('app.retrospectives.retrospective'),
      feedback: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedbacks'),
      feedbackSubmissions: this.modelFor('app.retrospectives.retrospective').retrospective.get('feedbackSubmissions'),
      // TODO: not game specific
      gameInput: ENV.retrospective["sticky_notes"].feedback
    });
  },
  setupController(controller, model) {
    const feedback = model.feedback;

    this._super(...arguments);

    controller.set('submitted', false);

    model.gameInput.forEach((feedback) => {
      set(feedback,'value', '');
    });

    const userFeedback = feedback.filter((fb) => {
      return parseInt(fb.get('user.id')) === parseInt(this.get('session').get('currentUser.id'));
    });

    if (typeof userFeedback !== "undefined" && userFeedback.length > 0) {
      this._markFeedbackSubmitted(userFeedback);
    }
  },
  _markFeedbackSubmitted(feedbacks) {
    if (feedbacks) {
      this.currentModel.gameInput.forEach((input) => {
        set(input, 'value', feedbacks.find((feedback) => {
          return feedback.get('category') === input.type;
        }).get('message'));
      });
    }
    this.controller.set('submitted', true);
  },
});