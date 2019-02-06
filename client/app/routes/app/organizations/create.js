import Route from '@ember/routing/route';
import { A } from '@ember/array';

export default Route.extend({
  model() {
    return this.store.createRecord('organization');
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('errors', {});
    controller.set('orgMemberEmails', A());
    controller.set('newMemberIndex', 1);
    controller.set('currentlyLoading', false);
    controller.set('unexpectedError', '');
    controller.set('orgError', '');
  },
});