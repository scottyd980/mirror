import Ember from 'ember';
import AjaxService from 'ember-ajax/services/ajax';
import config from '../config/environment';

export default AjaxService.extend({
  host: config.DS.host,
  namespace: config.DS.namespace,
  session: Ember.inject.service(),
  headers: {
    'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`
  }
});
