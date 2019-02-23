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
    controller.set('isLoading', false);
  },
  actions: {
    doRegister() {
      this.controller.set('isLoading', true);
      this.controller.set('errors', false);
      this.get('currentModel').save().then(() => {
        this.controller.set('isLoading', false);
        this.get('session')
          .authenticate('authenticator:mirror', this.get('currentModel').get('username'), this.get('currentModel').get('password'));
      }).catch((resp) => {
        this.controller.set('isLoading', false);
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