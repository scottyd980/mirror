import Route from '@ember/routing/route';
import ApplicationRouteMixin from 'ember-simple-auth/mixins/application-route-mixin';
import { hash } from 'rsvp';
import { inject as service } from '@ember/service';
import $ from 'jquery';

export default Route.extend(ApplicationRouteMixin, {
  session: service(),
  model() {
    return hash({});
  },
  setupController(controller, model) {
    const _this = this;
    _this._super(controller, model);

    if(_this.get('session.isAuthenticated')) {
      model.filteredTeams = _this.get('session.currentUser').get('teams').sortBy('id');
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
