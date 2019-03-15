import Route from '@ember/routing/route';
import ApplicationRouteMixin from 'ember-simple-auth/mixins/application-route-mixin';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';
import $ from 'jquery';
import ENV from 'mirror/config/environment';
import fetch from 'fetch';

export default Route.extend(ApplicationRouteMixin, {
  session: service(),
  beforeModel() {
    if(this.get('session.isAuthenticated') && !this.get('session.currentUser')) {
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
    } else {
      return;
    }
  },
  model() {
    return hash({});
  },
  setupController(controller, model) {
    this._super(...arguments);

    if(this.get('session.isAuthenticated')) {
      model.filteredTeams = this.get('session.currentUser').get('teams').sortBy('id');
    }

    controller.setProperties(model);
  },
  actions: {
    logout() {
      this.get('session').invalidate();
    },
    invalidateApplicationModel() {
      this.refresh();
    },
    scrollToLearnMore() {
      this.transitionTo('index').then(() => {
        setTimeout(() => {
          $('html, body').animate({
            scrollTop: $('#learn-more').offset().top - 80
          }, 500);
        }, 100);
      });
    }
  }
});
