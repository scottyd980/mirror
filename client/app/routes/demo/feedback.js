import RetrospectiveRoute from 'mirror/routes/demo/extends/retrospective';
import ENV from 'mirror/config/environment';
import { schedule } from '@ember/runloop';
import { set } from '@ember/object';

export default RetrospectiveRoute.extend({
  model() {
    return {
      team_members: ENV.DEMO.team_members,
      retrospective: ENV.DEMO.retrospectives[1],
      team: ENV.DEMO.team,
      feedback: ENV.DEMO.retrospectives[1].feedbacks,
      feedbackSubmissions: ENV.DEMO.retrospectives[1].feedback_submissions,
      gameInput: ENV.retrospective["sticky_notes"].feedback
    }
  },
  setupController(controller, model) {
    this._super(...arguments);

    if(ENV.DEMO.user_feedback.length === 0) {
      // Reset fields, assume they came from a new start.
      controller.set('submitted', false);
      model.gameInput.forEach((input) => {
        set(input, 'value', '');
      });
    }

    schedule('afterRender', this, function() {
      controller.start_tour(ENV.TOUR.feedback);
      controller.begin_feedback();
    });
  }
});