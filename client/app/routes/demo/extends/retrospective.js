import Route from '@ember/routing/route';
import UnauthenticatedRouteMixin from 'ember-simple-auth/mixins/unauthenticated-route-mixin';
import { inject as service } from '@ember/service';
import ENV from 'mirror/config/environment';

export default Route.extend(UnauthenticatedRouteMixin, {
  tour: service(),
  beforeModel() {
    if(ENV.DEMO_CONFIG.state !== "in_progress") {
      this.transitionTo('demo');
    }
  },
  actions: {
    willTransition: function() {
      if(this.get('tour.tourObject')) {
        this.get('tour').cancel();
      }
    }
  }
});