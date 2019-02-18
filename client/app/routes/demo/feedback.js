import RetrospectiveRoute from 'mirror/routes/demo/extends/retrospective';
import ENV from 'mirror/config/environment';
import { schedule } from '@ember/runloop';

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

    schedule('afterRender', this, function() {
      controller.start_tour();
    });
  }
});