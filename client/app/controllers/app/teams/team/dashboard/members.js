import Controller from '@ember/controller';
import fetch from 'fetch';
import { inject as service } from '@ember/service';
import ENV from 'mirror/config/environment';
import $ from 'jquery';
import { set } from '@ember/object';

export default Controller.extend({
  session: service(),
  isAdmin: false,
  confirmRemoveModal: false,
  showAddTeamMembersModal: false,
  adminWarning: false,
  teamMemberEmails: null,
  newMemberIndex: null,
  actions: {
    cancelAddTeamMembers() {
      this.set('showAddTeamMembersModal', false);
    },
    addTeamMemberEmail(teamMember) {
      const idx = this.get('newMemberIndex');

      this.get('teamMemberEmails').pushObject({
        email: teamMember,
        index: idx,
        error: null,
      });
      this.set('newMemberIndex', idx + 1);
      this.set('newTeamMemberEmail', '');
      setTimeout(() => {
        $('#team-member-email-' + idx).focus();
      }, 0);
    },
    removeTeamMemberEmail(teamMember) {
      this.get('teamMemberEmails').removeObject(teamMember);
    },
    toggleModal() {
      this.toggleProperty('confirmRemoveModal');
    },
    toggleAdminWarning() {
      this.toggleProperty('adminWarning');
    },
    addAdmin(member, team) {
      const _this = this;

      return fetch(`${ENV.DS.host}/${ENV.DS.namespace}/team_admins`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
          'Content-Type': 'application/vnd.api+json'
        },
        body: JSON.stringify({
          "admin_id": member.get('id'),
          "team_id": team.get('id')
        })
      }).then((response) => {
        if(response.status === ENV.STATUS_CODES.created || response.status === ENV.STATUS_CODES.ok) {
          _this.get('notifications').success({
            title: ENV.SUCCESS_MESSAGES.generic,
            message: "The team member was successfully promoted to team admin."
          });
          _this.get('model').team.reload();
        } else {
          throw new Error('Unexpected response from server');
        }
      }).catch(() => {
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.process,
          message: "We experienced an unexpected error. Please try again."
        });
      });
    },
    removeAdmin(member, team) {
      const _this = this;

      return fetch(`${ENV.DS.host}/${ENV.DS.namespace}/team_admins`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
          'Content-Type': 'application/vnd.api+json'
        },
        body: JSON.stringify({
          "admin_id": member.get('id'),
          "team_id": team.get('id')
        })
      }).then((response) => {
        if(response.status === ENV.STATUS_CODES.ok) {
          _this.get('notifications').success({
            title: ENV.SUCCESS_MESSAGES.generic,
            message: "The team member is no longer an admin."
          });
          _this.get('model').team.reload();
        } else {
          throw new Error('Unexpected response from server');
        }
      }).catch(() => {
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.process,
          message: "We experienced an unexpected error. Please try again."
        });
      });
    },
    deleteMember(member, team) {
      const _this = this;

      return fetch(`${ENV.DS.host}/${ENV.DS.namespace}/team_members`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
          'Content-Type': 'application/vnd.api+json'
        },
        body: JSON.stringify({
          "user_id": member.get('id'),
          "team_id": team.get('id')
        })
      }).then((response) => {
        if(response.status === ENV.STATUS_CODES.ok) {
          response.json().then(() => {
            if(this.get('model').currentUser.get('id') === member.get('id')) {
              _this.transitionToRoute('app');
              _this.send('invalidateApplicationModel');
            }
            _this.get('model').members.reload();
          });
        } else if(response.status === ENV.STATUS_CODES.forbidden) {
          // Can't delete last remaining admin
          _this.get('notifications').error({
            title: ENV.ERROR_MESSAGES.generic,
            message: "It looks like you're currently the only admin on the team. In order to leave the team, you must assign another admin. If you would like to delete the team instead, please go to the team's preferences."
          });
        } else {
          throw new Error('Unexpected response from server');
        }
      }).catch(() => {
        this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.process,
          message: "We experienced an unexpected error. Please try again."
        });
      });
    },

    addTeamMembers() {
      const _this = this;
      let delegates = [],
        membersToAdd = [],
        errors = [];
      
      _this.set('teamError', '');
      _this.set('unexpectedError', '');
      _this.set('currentlyLoading', true);

      // _this.get('currentModel').set('admin', _this.get('session').get('currentUser'));

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

      if(errors.length > 0) {
        errors.forEach((item) => {
          set(item, 'error', "This doesn't look like a valid email address!");
        });
        _this.set('currentlyLoading', false);
        return;
      }

      delegates = membersToAdd.map((item) => {
        return item.email;
      });

      _this.set('showAddTeamMembersModal', false);

      return fetch(`${ENV.DS.host}/${ENV.DS.namespace}/member_delegates`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
          'Content-Type': 'application/vnd.api+json'
        },
        body: JSON.stringify({
          "data": {
            "team_id": _this.get('model').team.id,
            "delegates": delegates
          }
        })
      }).then((response) => {
        if(response.status === ENV.STATUS_CODES.created || response.status === ENV.STATUS_CODES.ok) {
          response.json().then(() => {
            _this.get('notifications').success({
              title: ENV.SUCCESS_MESSAGES.generic,
              message: "Your new team member invitations have been sent. Once they accept your invitation, they will show up on the team members page."
            }); 
          });
        } else {
          throw new Error('Unexpected response from server');
        }
      }).catch(() => {
        _this.get('notifications').error({
          title: ENV.ERROR_MESSAGES.generic,
          message: "We experienced an unexpected error trying to send team member invitations. Please try again."
        });
      });
    }
  }
});
