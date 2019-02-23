import Route from '@ember/routing/route';
import fetch from 'fetch';
import ENV from 'mirror/config/environment';

export default Route.extend({
  model(params) {
    return {
      reset_token: params.uuid,
      new_password: '',
      new_password_confirmation: ''
    };
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('success', false);
    controller.set('info', false);
    controller.set('errors', {});
    controller.set('isLoading', false);
  },
  actions: {
    doReset() {
      this.controller.set('isLoading', true);
      this.controller.set('success', false);
      this.controller.set('info', false);
      this.controller.set('errors', {});
      const reset = this.get('currentModel');
      fetch(`${ENV.DS.host}/${ENV.DS.namespace}/reset/password`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          "reset_token": reset.reset_token,
          "new_password": reset.new_password,
          "new_password_confirmation": reset.new_password_confirmation
        })
      }).then((response) => {
        this.controller.set('isLoading', false);
        if(response.status === 200) {
          response.json().then(() => {
            this.controller.set('errors', false);
            this.controller.set('info', false);
            this.controller.set('success', true);
          });
        } else if(response.status === 404) {
          this.controller.set('errors', false);
          this.controller.set('success', false);
          this.controller.set('info', true);
        } else {
          this.controller.set('info', false);
          this.controller.set('success', false);
          response.json().then((resp) => {
            const { errors } = resp;
            this.controller.set('errors', this._createErrors(errors));
          });
        }
      }).catch((resp) => {
        this.controller.set('isLoading', false);
        this.controller.set('info', false);
        this.controller.set('success', false);
        const { errors } = resp;
        this.controller.set('errors', this._createErrors(errors));
      });
    }
  },
  _createErrors(errors) {
    var validations = {
      length: 0
    };

    errors.forEach(function(item) {
      var pointer = item.source.pointer.substring(item.source.pointer.lastIndexOf('/') + 1) + "-error";
      validations[pointer] = item.detail + ".";
      validations.length++;
    });

    return validations;
  }
});
