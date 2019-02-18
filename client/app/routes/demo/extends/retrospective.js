import Route from '@ember/routing/route';
import UnauthenticatedRouteMixin from 'ember-simple-auth/mixins/unauthenticated-route-mixin';
import { inject as service } from '@ember/service';

export default Route.extend(UnauthenticatedRouteMixin, {
  tour: service(),
  actions: {
    willTransition: function() {
      if(this.get('tour.tourObject')) {
        this.get('tour').cancel();
      }
    }
  }
});