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
  setupController(controller, model) {
    this._super(...arguments);

    if(ENV.DEMO.user_score.length === 0) {
      // Reset fields, assume they came from a new start.
      controller.set('submitted', false);
      this.controller.set('score', null);
    }

    schedule('afterRender', this, function() {
      controller.start_tour(ENV.TOUR.score);
      controller.begin_score();
    });
  }
});
