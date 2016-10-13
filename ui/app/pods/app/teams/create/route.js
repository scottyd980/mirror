import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('team');
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('errors', {});
    controller.set('teamMemberEmails', Ember.A());
  },
  actions: {
    addTeamMemberEmail() {
      var _this = this;
      _this.controller.get('teamMemberEmails').pushObject(_this.controller.get('newTeamMemberEmail'));
      _this.controller.set('newTeamMemberEmail', '');
    }
  }
});
