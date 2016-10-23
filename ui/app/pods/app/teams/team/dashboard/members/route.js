import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Route.extend({
  session: Ember.inject.service('session'),
  model() {
    var _this = this;
    return RSVP.hash({
      team: this.modelFor('app.teams.team'),
      members: this.modelFor('app.teams.team').get('members'),
      currentUser: _this.get('session').get('currentUser')
    });
  },
  setupController(controller, models) {
    var _this = this;
    _this._super(controller, models);

    controller.set('isAdmin', models.currentUser.get('id') === models.team.get('admin.id'));
  }
});
