import Ember from 'ember';
import ENV from 'mirror/config/environment';

export default Ember.Controller.extend({
  session: Ember.inject.service('session'),
  billing_active: ENV.FLAGS.billing,
  actions: {
    navbarCollapse(target) {
      // Do not collapse on desktop (i.e. if the button navbar toggle is hidden)
      if (Ember.$('button.navbar-toggle').is(':hidden')) {
        return;
      }
      // Do not collapse if target is a sub menu
      if (Ember.$(target).hasClass('dropdown-toggle')) {
        return;
      }

      Ember.$('.navbar-collapse').collapse('hide');
    }
  }
});
