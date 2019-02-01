import Route from '@ember/routing/route';
import ENV from 'mirror/config/environment';

export default Route.extend({
  // TODO: socket: service(),
  model(params) {
    const _this = this;
    return _this.get('store').findRecord('team', params.id).catch(() => {
      throw ENV.ERROR_CODES.not_found;
    });
  }
});
