import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import ENV from 'mirror/config/environment';
import { inject as service } from '@ember/service';

export default Route.extend({
  session: service(),
  model() {
    return hash({
      team: this.modelFor('app.teams.team'),
      user_organizations: this.get('session.currentUser').get('organizations'),
      currentUser: this.get('session').get('currentUser')
    });
  },
  setupController(controller) {
    this._super(...arguments);
    controller.set('isJoinOwnOrganizationModalShowing', false);
    controller.set('isCreateNewOrganizationModalShowing', false);
    controller.set('isJoinAnotherOrganizationModalShowing', false);
    controller.set('newOrganizationName', '');
    controller.set('orgError', '');

    controller.set('active_billing_types', ENV.ACTIVE_BILLING_TYPES);
  },
});