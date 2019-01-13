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
    controller.set('newMemberIndex', 2);
    controller.set('session', this.session);
    controller.set('teamError', '');
    controller.set('unexpectedError', '');
    controller.set('currentlyLoading', false);

    controller.get('teamMemberEmails').pushObject({
      email: "",
      index: 1
    });
  },
  actions: {
    addTeamMemberEmail(teamMember) {
      var _this = this;
      var idx = _this.controller.get('newMemberIndex');

      _this.controller.get('teamMemberEmails').pushObject({
        email: teamMember,
        index: idx,
        error: null,
      });
      _this.controller.set('newMemberIndex', idx + 1);
      _this.controller.set('newTeamMemberEmail', '');
      setTimeout(() => {
        $('#team-member-email-' + idx).focus();
      }, 0);
    },
    removeTeamMemberEmail(teamMember) {
      var _this = this;
      _this.controller.get('teamMemberEmails').removeObject(teamMember);
    },
    createTeam() {
      var _this = this,
        delegates = [],
        membersToAdd = [],
        errors = [];
      
      _this.controller.set('teamError', '');
      _this.controller.set('unexpectedError', '');
      _this.controller.set('currentlyLoading', true);

      _this.get('currentModel').set('admin', _this.get('session').get('currentUser'));

      membersToAdd = _this.controller.get('teamMemberEmails');

      membersToAdd.forEach((item) => {
        Ember.set(item, 'error', null);
      });
      
      membersToAdd = membersToAdd.filter((item) => {
        return item.email !== "" && item.email;
      });
      
      errors = membersToAdd.filter((item) => {
        return !item.email.match(/^[^@\s]+@[^@\s]+\.[^@\s]+$/);
      });

      if(errors.length > 0) {
        errors.forEach((item) => {
          Ember.set(item, 'error', "This doesn't look like a valid email address!");
        });
        _this.controller.set('currentlyLoading', false);
        return;
      } else if(!_this.get('currentModel').get('name') || _this.get('currentModel').get('name').trim() === "") {
        _this.controller.set('teamError', 'Your team needs a name!');
        _this.controller.set('currentlyLoading', false);
        return;
      }

      delegates = membersToAdd.map((item) => {
        return item.email;
      });

      _this.get('currentModel').set('memberDelegates', delegates);

      _this.get('currentModel').save().then(() => {
        _this.controller.set('teamMemberEmails', Ember.A());
        _this.controller.set('newTeamMemberEmail', '');
        _this.send('invalidateApplicationModel');
        _this.transitionTo('app.teams.team.dashboard.retrospectives', _this.get('currentModel'));
        _this.controller.set('currentlyLoading', false);
      }).catch(() => {
        _this.controller.set('unexpectedError', 'There was an unexpected error, please review the fields and try again.');
        _this.controller.set('currentlyLoading', false);
      });
    }
  }
});
