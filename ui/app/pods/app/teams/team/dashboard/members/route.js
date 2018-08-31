import Ember from 'ember';
import RSVP from 'rsvp';
import config from '../../../../../../config/environment';

export default Ember.Route.extend({
  session: Ember.inject.service('session'),
  model() {
    var _this = this;
    return RSVP.hash({
      team: _this.modelFor('app.teams.team'),
      members: _this.modelFor('app.teams.team').get('members'),
      currentUser: _this.get('session').get('currentUser')
    });
  },
  setupController(controller, models) {
    var _this = this;
    _this._super(controller, models);

    controller.set('isAdmin', models.team.get('admins').includes(models.currentUser));
    controller.set('confirmRemoveModal', false);
    controller.set('adminWarning', false);

    controller.set('teamMemberEmails', Ember.A());
    controller.set('newMemberIndex', 2);
    controller.get('teamMemberEmails').pushObject({
      email: "",
      index: 1
    });

    controller.set('showAddTeamMembersModal', false);
  },
  actions: {
    cancelAddTeamMembers() {
      this.controller.set('showAddTeamMembersModal', false);
    },
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
    toggleModal() {
      this.controller.toggleProperty('confirmRemoveModal');
    },
    toggleAdminWarning() {
      this.controller.toggleProperty('adminWarning');
    },
    addAdmin(member, team) {
      var _this = this;

      return fetch(`${config.DS.host}/${config.DS.namespace}/team_admins`, {
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
        if(response.status === config.STATUS_CODES.created || response.status === config.STATUS_CODES.ok) {
          _this.get('notificationCenter').success({
            title: config.SUCCESS_MESSAGES.generic,
            message: "The team member was successfully promoted to team admin."
          });
          _this.controller.get('model').team.reload();
        } else {
          if(response.status === config.STATUS_CODES.unprocessable_entity) {
            _this.get('notificationCenter').error({
              title: config.ERROR_MESSAGES.generic,
              message: "We experienced an unexpected error. Please try again."
            });
          }
        }
      });
    },
    removeAdmin(member, team) {
      var _this = this;

      return fetch(`${config.DS.host}/${config.DS.namespace}/team_admins`, {
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
        if(response.status === config.STATUS_CODES.ok) {
          _this.get('notificationCenter').success({
            title: config.SUCCESS_MESSAGES.generic,
            message: "The team member is no longer an admin."
          });
          _this.controller.get('model').team.reload();
        } else {
          if(response.status === config.STATUS_CODES.unprocessable_entity) {
            _this.get('notificationCenter').error({
              title: config.ERROR_MESSAGES.generic,
              message: "We experienced an unexpected error. Please try again."
            });
          }
        }
      });
    },
    deleteMember(member, team) {
      var _this = this;

      return fetch(`${config.DS.host}/${config.DS.namespace}/team_members`, {
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
        if(response.status === config.STATUS_CODES.ok) {
          response.json().then(() => {
            if(this.get('currentModel').currentUser.get('id') === member.get('id')) {
              _this.transitionTo('app');
              _this.send('invalidateApplicationModel');
            }
            _this.controller.get('model').members.reload();
          });
        } else if(response.status === config.STATUS_CODES.forbidden) {
          // Can't delete last remaining admin
          _this.get('notificationCenter').error({
            title: config.ERROR_MESSAGES.generic,
            message: "It looks like you're currently the only admin on the team. In order to leave the team, you must assign another admin. If you would like to delete the team instead, please go to the team's preferences."
          });
        } else {
          _this.get('notificationCenter').error({
            title: config.ERROR_MESSAGES.generic,
            message: "We experienced an unexpected error. Please try again."
          });
        }
      });
    },

    addTeamMembers() {
      var _this = this,
        delegates = [],
        membersToAdd = [],
        errors = [];
      
      _this.controller.set('teamError', '');
      _this.controller.set('unexpectedError', '');
      _this.controller.set('currentlyLoading', true);

      // _this.get('currentModel').set('admin', _this.get('session').get('currentUser'));

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
      }

      delegates = membersToAdd.map((item) => {
        return item.email;
      });

      _this.controller.set('showAddTeamMembersModal', false);

      return fetch(`${config.DS.host}/${config.DS.namespace}/member_delegates`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`,
          'Content-Type': 'application/vnd.api+json'
        },
        body: JSON.stringify({
          "data": {
            "team_id": _this.controller.get('model').team.id,
            "delegates": delegates
          }
        })
      }).then((response) => {
        if(response.status === config.STATUS_CODES.created || response.status === config.STATUS_CODES.ok) {
          response.json().then((resp) => {
            _this.get('notificationCenter').success({
              title: config.SUCCESS_MESSAGES.generic,
              message: "Your new team member invitations have been sent. Once they accept your invitation, they will show up on the team members page."
            }); 
          });
        } else {
          _this.get('notificationCenter').error({
            title: config.ERROR_MESSAGES.generic,
            message: "We experienced an unexpected error trying to send team member invitations. Please try again."
          });
        }
      }).catch(() => {
        _this.get('notificationCenter').error({
          title: config.ERROR_MESSAGES.generic,
          message: "We experienced an unexpected error trying to send team member invitations. Please try again."
        });
      });
    }
  }
});
