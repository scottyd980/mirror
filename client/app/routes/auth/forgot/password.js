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
  },
  actions: {
    doReset() {
      var _this = this;
      _this.controller.set('success', false);
      _this.controller.set('errors', false);
      const user = this.get('currentModel');
      fetch(`${ENV.DS.host}/${ENV.DS.namespace}/forgot/password`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          "email": user.email
        })
      }).then((response) => {
        if(response.status === 200) {
          response.json().then(() => {
            _this.controller.set('errors', false);
            _this.controller.set('success', true);
          });
        } else {
          _this.controller.set('success', false);
          _this.controller.set('errors', true);
        }
      }).catch(() => {
        _this.controller.set('success', false);
        _this.controller.set('errors', true);
      });
    }
  }
});
