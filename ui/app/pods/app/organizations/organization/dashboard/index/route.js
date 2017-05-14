import Ember from 'ember';

export default Ember.Route.extend({
  redirect: function() {
    this.transitionTo('app.organizations.organization.dashboard.billing');
  }
});
