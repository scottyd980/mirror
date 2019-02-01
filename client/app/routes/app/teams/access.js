import Route from '@ember/routing/route';
import ENV from 'mirror/config/environment';
import { inject as service } from '@ember/service';
import fetch from 'fetch'

export default Route.extend({
  session: service(),
  model(params) {
    return {
      access_code: params.access_code
    };
  },
  afterModel(model) {
    return fetch(`${ENV.DS.host}/${ENV.DS.namespace}/team_members`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
        'Content-Type': 'application/vnd.api+json'
      },
      body: JSON.stringify({
        "access-code": model.access_code
      })
    }).then((response) => {
      if (response.status === ENV.STATUS_CODES.created || response.status === ENV.STATUS_CODES.ok) {
        response.json().then((resp) => {
          this.send('invalidateApplicationModel');
          this.transitionTo('app.teams.team.dashboard.retrospectives', resp.data.relationships.team.data.id);
        });
      } else {
        // TODO: Test this and catch this
        if (response.status === ENV.STATUS_CODES.unprocessable_entity) {
          throw ENV.ERROR_CODES.server_error;
        }
      }
    });
  }
});
