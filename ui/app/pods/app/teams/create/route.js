import Ember from 'ember';

export default Ember.Route.extend({
  session: Ember.inject.service('session'),
  model() {
    return this.store.createRecord('team');
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('errors', {});
    controller.set('teamMemberEmails', Ember.A());
    controller.set('newMemberIndex', 1);
  },
  actions: {
    addTeamMemberEmail(teamMember) {
      var _this = this;
      var idx = _this.controller.get('newMemberIndex');

      _this.controller.get('teamMemberEmails').pushObject({
        email: teamMember,
        index: idx
      });
      _this.controller.set('newMemberIndex', idx + 1);
      _this.controller.set('newTeamMemberEmail', '');
      $('#team-member-add').focus();
    },
    removeTeamMemberEmail(teamMember) {
      var _this = this;
      _this.controller.get('teamMemberEmails').removeObject(teamMember);
    },
    createTeam() {
      var _this = this,
        delegates = [];

      _this.get('currentModel').set('admin', _this.get('session').get('currentUser'));

      var membersToAdd = _this.controller.get('teamMemberEmails');

      membersToAdd.map((item) => {
        delegates.push(item.email);
      });

      _this.get('currentModel').set('memberDelegates', delegates);

      _this.get('currentModel').save().then(() => {
        _this.send('invalidateApplicationModel');
      });
    }
  }
});
