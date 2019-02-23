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
    controller.set('isLoading', false);
  },
  actions: {
    doLogin() {
      this.controller.set('errors', false);
      this.controller.set('isLoading', true);
      const user = this.get('currentModel');

      this.get('session').authenticate('authenticator:mirror', user.username, user.password)
      .then(() => {
        this.controller.set('isLoading', false);
        this.send('invalidateApplicationModel');
      }).catch(() => {
        this.controller.set('isLoading', false);
        this.controller.set('errors', true);
      });
    }
  }
});