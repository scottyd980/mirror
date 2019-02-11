import Route from '@ember/routing/route';
import ENV from 'mirror/config/environment';
import { inject as service } from '@ember/service';

export default Route.extend({
  socket: service(),
  model(params) {
    const _this = this;
    return _this.get('store').findRecord('team', params.id).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });
  }
});
