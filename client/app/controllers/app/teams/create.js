import Controller from '@ember/controller';
import $ from 'jquery';
import { inject as service } from '@ember/service';
import { set } from '@ember/object';
import { A } from '@ember/array';

export default Controller.extend({
  session: service(),
  actions: {
    addTeamMemberEmail(teamMember) {
      const _this = this;
      const idx = _this.get('newMemberIndex');

      _this.get('teamMemberEmails').pushObject({
        email: teamMember,
        index: idx,
        error: null,
      });
      _this.set('newMemberIndex', idx + 1);
      _this.set('newTeamMemberEmail', '');
      setTimeout(() => {
        $('#team-member-email-' + idx).focus();
      }, 0);
    },
    removeTeamMemberEmail(teamMember) {
      const _this = this;
      _this.get('teamMemberEmails').removeObject(teamMember);
    },
    createTeam() {
      let _this = this,
        delegates = [],
        membersToAdd = [],
        errors = [];

      _this.set('teamError', '');
      _this.set('unexpectedError', '');
      _this.set('currentlyLoading', true);

      _this.get('model').set('admin', _this.get('session').get('currentUser'));

      membersToAdd = _this.get('teamMemberEmails');

      membersToAdd.forEach((item) => {
        set(item, 'error', null);
      });

      membersToAdd = membersToAdd.filter((item) => {
        return item.email !== "" && item.email;
      });

      errors = membersToAdd.filter((item) => {
        return !item.email.match(/^[^@\s]+@[^@\s]+\.[^@\s]+$/);
      });

      if (errors.length > 0) {
        errors.forEach((item) => {
          set(item, 'error', "This doesn't look like a valid email address!");
        });
        _this.set('currentlyLoading', false);
        return;
      } else if (!_this.get('model').get('name') || _this.get('model').get('name').trim() === "") {
        _this.set('teamError', 'Your team needs a name!');
        _this.set('currentlyLoading', false);
        return;
      }

      delegates = membersToAdd.map((item) => {
        return item.email;
      });

      _this.get('model').set('memberDelegates', delegates);

      _this.get('model').save().then(() => {
        _this.set('teamMemberEmails', A());
        _this.set('newTeamMemberEmail', '');
        _this.send('invalidateApplicationModel');
        _this.transitionToRoute('app.teams.team.dashboard.retrospectives', _this.get('model'));
        _this.set('currentlyLoading', false);
      }).catch(() => {
        _this.set('unexpectedError', 'There was an unexpected error, please review the fields and try again.');
        _this.set('currentlyLoading', false);
      });
    }
  }
});
