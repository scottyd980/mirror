import JSONAPIAdapter from 'ember-data/adapters/json-api';
import DataAdapterMixin from 'ember-simple-auth/mixins/data-adapter-mixin';
import ENV from 'mirror/config/environment';
import { inject as service } from '@ember/service';
import { isPresent } from '@ember/utils';

export default JSONAPIAdapter.extend(DataAdapterMixin, {
  session: service(),
  host: ENV.DS.host,
  namespace: ENV.DS.namespace,
  authorize(xhr) {
    let { access_token } = this.get('session.data.authenticated');
    if (isPresent(access_token)) {
      xhr.setRequestHeader('Authorization', `Bearer ${access_token}`);
    }
  },

  urlForCreateRecord(modelName/*, snapshot*/) {
    switch(modelName) {
      case 'user':
      case 'users':
        return this._super.apply(this, arguments).replace('users', 'register');
      default:
        return this._super(...arguments);
    }
  }
});
