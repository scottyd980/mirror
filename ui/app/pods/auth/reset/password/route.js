import Ember from 'ember';
import fetch from 'ember-network/fetch';
import config from 'mirror/config/environment';

export default Ember.Route.extend({
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
  },
  actions: {
    doReset() {
      var _this = this;
      _this.controller.set('success', false);
      _this.controller.set('info', false);
      _this.controller.set('errors', {});
      const reset = this.get('currentModel');
      fetch(`${config.DS.host}/${config.DS.namespace}/reset/password`, {
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
        if(response.status === 200) {
          response.json().then((uuid) => {
            _this.controller.set('errors', false);
            _this.controller.set('info', false);
            _this.controller.set('success', true);
          });
        } else if(response.status === 404) {
          _this.controller.set('errors', false);
          _this.controller.set('success', false);
          _this.controller.set('info', true);
        } else {
          _this.controller.set('info', false);
          _this.controller.set('success', false);
          response.json().then((resp) => {
            const { errors } = resp;
            _this.controller.set('errors', _this._createErrors(errors));
          });
        }
      }).catch((resp) => {
        _this.controller.set('info', false);
        _this.controller.set('success', false);
        const { errors } = resp;
        _this.controller.set('errors', _this._createErrors(errors));
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
