import Route from '@ember/routing/route';
import ENV from 'mirror/config/environment';

export default Route.extend({
  model(params) {
    return this.get('store').findRecord('organization', params.id).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });
  },
  redirect(model) {
    this.transitionTo('app.organizations.organization.dashboard', model);
  },
});
