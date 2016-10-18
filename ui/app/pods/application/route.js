import Ember from 'ember';
import ApplicationRouteMixin from 'ember-simple-auth/mixins/application-route-mixin';
import RSVP from 'rsvp';

const { Route, inject } = Ember;

export default Ember.Route.extend(ApplicationRouteMixin, {
  session: inject.service(),
  model() {
    return RSVP.hash({});
  },
  setupController(controller, models) {
    var _this = this;
    _this._super(controller, models);

    if(_this.get('session.isAuthenticated')) {
      models.filteredTeams = _this.get('session.currentUser').get('teams');
    }

    controller.setProperties(models);
  },
  actions: {
    logout() {
      this.get('session').invalidate();
    },
    invalidateApplicationModel() {
      this.refresh();
    }
  }
});
