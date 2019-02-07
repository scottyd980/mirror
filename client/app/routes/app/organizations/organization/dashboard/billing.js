import Route from '@ember/routing/route';
import { inject as service } from '@ember/service';
import { hash } from 'rsvp';

export default Route.extend({
  session: service(),
  model() {
    return hash({
      organization: this.modelFor('app.organizations.organization'),
      currentUser: this.get('session').get('currentUser'),
      cards: this.store.query('card', {
        filter: {
          organization: this.modelFor('app.organizations.organization').get('id')
        }
      })
    });
  },
  setupController(controller, models) {
    this._super(controller, models);

    controller.set('isAdmin', models.organization.get('admins').includes(models.currentUser));
    controller.set('currentlyLoading', false);
  },
});