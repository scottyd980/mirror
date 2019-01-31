import Route from '@ember/routing/route';
import { inject as service } from '@ember/service'; 

export default Route.extend({
  session: service(),
  model() {
    return {
      username: '',
      password: ''
    };
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('errors', false);
  },
  actions: {
    doLogin() {
      var _this = this;
      _this.controller.set('errors', false);
      const user = this.get('currentModel');
      this.get('session')
        .authenticate(
          'authenticator:mirror', user.username, user.password
        ).then(() => {
          this.send('invalidateApplicationModel');
        }).catch(() => {
          _this.controller.set('errors', true);
        });
    }
  }
});