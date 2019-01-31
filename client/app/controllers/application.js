import Controller from '@ember/controller';
import ENV from 'mirror/config/environment';
import $ from 'jquery';
import { inject as service } from '@ember/service';

export default Controller.extend({
  session: service(),
  actions: {
    billing_active: ENV.FLAGS.billing,
    navbarCollapse(target) {
      // Do not collapse on desktop (i.e. if the button navbar toggle is hidden)
      if ($('button.navbar-toggle').is(':hidden')) {
        return;
      }
      // Do not collapse if target is a sub menu
      if ($(target).hasClass('dropdown-toggle')) {
        return;
      }

      $('.navbar-collapse').collapse('hide');
    }
  }
});
