import RetrospectiveRoute from 'mirror/routes/demo/extends/retrospective';
import ENV from 'mirror/config/environment';

export default RetrospectiveRoute.extend({
  model() {
    return {
      team_members: ENV.DEMO.team_members,
      retrospective: ENV.DEMO.retrospectives[4],
      team: ENV.DEMO.team,
      scoreSubmissions: ENV.DEMO.retrospectives[4].score_submissions
    }
  }
});
