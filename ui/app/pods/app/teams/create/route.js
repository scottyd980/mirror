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
        delegates = [],
        membersToAdd = [];

      _this.get('currentModel').set('admin', _this.get('session').get('currentUser'));

      membersToAdd = _this.controller.get('teamMemberEmails');
      membersToAdd.push({
        email: _this.controller.get('newTeamMemberEmail')
      });

      delegates = membersToAdd.filter((item) => {
        return item.email != "" && item.email;
      }).map((item) => {
        return item.email;
      });

      _this.get('currentModel').set('memberDelegates', delegates);

      _this.get('currentModel').save().then(() => {
        _this.controller.set('teamMemberEmails', Ember.A());
        _this.controller.set('newTeamMemberEmail', '');
        _this.send('invalidateApplicationModel');
      });
    }
  }
});
