import Ember from 'ember';
import fetch from 'ember-network/fetch';
import config from 'mirror/config/environment';

export default Ember.Route.extend({
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
      const user = this.get('currentModel');
      fetch(`${config.DS.host}/${config.DS.namespace}/forgot/username`, {
        method: 'POST',
        body: JSON.stringify({
          "email": user.email
        })
      }).then((response) => {
        if(response.status === 200) {
          response.json().then((uuid) => {
            _this.controller.set('errors', false);
            _this.controller.set('success', true);
          });
        } else {
          _this.controller.set('success', false);
          _this.controller.set('errors', true);
        }
      }).catch((err) => {
        _this.controller.set('success', false);
        _this.controller.set('errors', true);
      });
    }
  }
});
