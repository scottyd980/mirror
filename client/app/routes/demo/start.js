import RetrospectiveRoute from 'mirror/routes/demo/extends/retrospective';
import ENV from 'mirror/config/environment';

export default RetrospectiveRoute.extend({
  beforeModel() {
    ENV.DEMO = JSON.parse(JSON.stringify(ENV.DEMO_CONFIG.base));
    ENV.DEMO_CONFIG.state = "in_progress";
  },
  model() {
    return {
      team_members: ENV.DEMO.team_members,
      current_user: ENV.DEMO.current_user,
      retrospective: ENV.DEMO.retrospectives[0]
    }
  },
  setupController(controller) {
    this._super(...arguments);
    controller.set('showModal', true)
  }
});