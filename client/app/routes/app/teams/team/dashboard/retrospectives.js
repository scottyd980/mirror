import Route from '@ember/routing/route';
import { hash } from 'rsvp';
import ENV from 'mirror/config/environment';
import fetch from 'fetch';
import { inject as service } from '@ember/service';

export default Route.extend({
  retrospective: service(),
  session: service(),
  model() {
    return hash({
      team: this.modelFor('app.teams.team'),
      nextSprint: fetch(`${ENV.DS.host}/${ENV.DS.namespace}/teams/${this.modelFor('app.teams.team').get('id')}/next_sprint`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
          'Content-Type': 'application/vnd.api+json'
        }
      }).then((response) => {
        return response.json();
      }).then((data) => {
        return data.next_sprint;
      }),
      currentUser: this.get('session').get('currentUser')
    })
  },
  
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('isAdmin', model.team.get('admins').includes(model.currentUser));
    
    controller.setProperties({
      hasRetroInProgress: false,
      isRetroStartModalShowing: false,
      iseBillingModalShowing: false,
      gameToStart: null,
      currentlyLoading: false
    });

    const retro = this.get('retrospective').join_team_channel(model.team.get('id'));

    controller.set('retrospective', retro);
  },
});
