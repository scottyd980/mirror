import Ember from 'ember';
import config from '../../../../config/environment';

export default Ember.Route.extend({
  model(params) {
    var _this = this;
    return _this.get('store').findRecord('organization', params.id).catch(() => {
      throw config.ERROR_CODES.not_found;
    });
  },
  setupController(controller, model) {
    this._super(controller, model);
  }
});
