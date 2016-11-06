import Ember from 'ember';
import config from '../../../../config/environment';

export default Ember.Route.extend({
  session: Ember.inject.service(),
  model(params) {
    return {
      access_code: params.access_code
    };
  },
  afterModel(model) {
    return fetch(`${config.DS.host}/${config.DS.namespace}/team_users`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
        'Content-Type': 'application/vnd.api+json'
      },
      body: JSON.stringify({
        "access-code": model.access_code
      })
    }).then((response) => {
      if(response.status === config.STATUS_CODES.created || response.status === config.STATUS_CODES.ok) {
        response.json().then((resp) => {
          this.transitionTo('app.teams.team.dashboard.retrospectives', resp.data.attributes.team_id);
        });
      } else {
        if(response.status === config.STATUS_CODES.unprocessable_entity) {
          throw config.ERROR_CODES.server_error;
        } else {
          throw config.ERROR_CODES.not_found;
        }
      }
    });
  }
});
