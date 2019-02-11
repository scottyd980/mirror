import Route from '@ember/routing/route';
import { inject as service } from '@ember/service';

export default Route.extend({
  session: service(),
  model() {
    return this.store.createRecord('user');
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('errors', {});
  },
  actions: {
    doRegister() {
      var _this = this;
      _this.controller.set('errors', false);
      _this.get('currentModel').save().then(() => {
        _this.get('session')
          .authenticate('authenticator:mirror', _this.get('currentModel').get('username'), _this.get('currentModel').get('password'));
      }).catch((resp) => {
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