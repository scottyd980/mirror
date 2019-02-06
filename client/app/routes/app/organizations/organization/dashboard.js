import Route from '@ember/routing/route';
import { inject as service } from '@ember/service';
import { hash } from 'rsvp';

export default Route.extend({
  session: service(),
  model() {
    return hash({
      organization: this.modelFor('app.organizations.organization'),
      //TODO: Remove?
      currentUser: this.get('session').get('currentUser')
    });
  },
  setupController(controller, models) {
    this._super(controller, models);
    controller.set('isAdmin', models.organization.get('admins').includes(models.currentUser));
  }
});