import Ember from 'ember';
import config from '../../../../config/environment';

export default Ember.Route.extend({
    socket: Ember.inject.service('socket-service'),
    retrospectiveService: Ember.inject.service('retrospective-service'),
    model(params) {
        var _this = this;
        return _this.get('store').findRecord('retrospective', params.id).catch(() => {
            throw config.ERROR_CODES.not_found;
        });
    }
});
