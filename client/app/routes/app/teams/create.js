import Route from '@ember/routing/route';
import { A } from '@ember/array';
import { inject as service } from '@ember/service';

export default Route.extend({
  session: service(),
  model() {
    return this.store.createRecord('team');
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('errors', {});
    controller.set('teamMemberEmails', A());
    controller.set('newMemberIndex', 2);
    controller.set('session', this.session);
    controller.set('teamError', '');
    controller.set('unexpectedError', '');
    controller.set('currentlyLoading', false);

    controller.get('teamMemberEmails').pushObject({
      email: "",
      index: 1
    });
  }
});
