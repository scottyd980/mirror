import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
  session: Ember.inject.service('session'),
  model() {
    var _this = this;
    return RSVP.hash({
      organization: this.modelFor('app.organizations.organization'),
      currentUser: _this.get('session').get('currentUser')
    });
  },
  setupController(controller, models) {
    var _this = this;
    _this._super(controller, models);

    controller.set('isAdmin', models.organization.get('admins').includes(models.currentUser));
  }
});
