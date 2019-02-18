import RetrospectiveRoute from 'mirror/routes/demo/extends/retrospective';
import ENV from 'mirror/config/environment';
import { schedule } from '@ember/runloop';

export default RetrospectiveRoute.extend({
  model() {
    return {
      team_members: ENV.DEMO.team_members,
      retrospective: ENV.DEMO.retrospectives[4],
      team: ENV.DEMO.team,
      scoreSubmissions: ENV.DEMO.retrospectives[4].score_submissions
    }
  },
  setupController(controller) {
    this._super(...arguments);

    schedule('afterRender', this, function() {
      controller.start_tour(ENV.TOUR.score);
    });
  }
});
