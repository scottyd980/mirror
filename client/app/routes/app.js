import Route from '@ember/routing/route';
import ENV from 'mirror/config/environment'
import fetch from 'fetch';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';
import { inject as service } from '@ember/service';

export default Route.extend(AuthenticatedRouteMixin, {
  session: service(),
  afterModel() {
    return fetch(`${ENV.DS.host}/${ENV.DS.namespace}/user/current`, {
      type: 'GET',
      headers: {
        'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`
      }
    }).then((raw) => {
      return raw.json().then((data) => {
        const currentUser = this.store.push(data);
        this.set('session.currentUser', currentUser);
      });
    });
  },
  actions: {
    // confirmAction(message, action) {
    //     this.get('notificationCenter').confirm({
    //         title: ENV.CONFIRM_MESSAGES.generic,
    //         message: message,
    //         action: action
    //     });
    // },
    // closeConfirm(action) {
    //   action();
    //   this.get('notificationCenter').clear();
    // }
  }
});