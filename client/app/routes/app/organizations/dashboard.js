import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';

export default Route.extend({
  session: service(),
  model() {
    return hash({
      organizations: this.get('session.currentUser').get('organizations').sortBy('id')
    });
  }
});
