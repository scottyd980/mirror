import RetrospectiveRoute from 'mirror/routes/demo/extends/retrospective';
import ENV from 'mirror/config/environment';

export default RetrospectiveRoute.extend({
  fromBack: false,
  beforeModel() {
    if(ENV.DEMO_CONFIG.state !== "in_progress") {
      ENV.DEMO = JSON.parse(JSON.stringify(ENV.DEMO_CONFIG.base));
      ENV.DEMO_CONFIG.state = "in_progress";
      this.set('fromBack', false);
    } else {
      this.set('fromBack', true);
    }
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
    if(!this.get('fromBack')) {
      controller.set('showModal', true);
    }
  }
});