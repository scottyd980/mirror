import Route from '@ember/routing/route';
import fetch from 'fetch';
import ENV from 'mirror/config/environment';

export default Route.extend({
  model() {
    return {
      email: ''
    };
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('success', false);
    controller.set('errors', false);
    controller.set('isLoading', false);
  },
  actions: {
    doReset() {
      this.controller.set('success', false);
      this.controller.set('errors', false);
      this.controller.set('isLoading', true);
      const user = this.get('currentModel');
      fetch(`${ENV.DS.host}/${ENV.DS.namespace}/forgot/username`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          "email": user.email
        })
      }).then((response) => {
        this.controller.set('isLoading', false);
        if(response.status === 200) {
          response.json().then(() => {
            this.controller.set('errors', false);
            this.controller.set('success', true);
          });
        } else {
          this.controller.set('success', false);
          this.controller.set('errors', true);
        }
      }).catch(() => {
        this.controller.set('isLoading', false);
        this.controller.set('success', false);
        this.controller.set('errors', true);
      });
    }
  }
});
