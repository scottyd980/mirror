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
  },
  actions: {
    toggleModal(member, team) {
      this.controller.toggleProperty('confirmRemoveModal');
    },
    toggleAdminWarning() {
      this.controller.toggleProperty('adminWarning');
    },
    confirmAction(message, action) {
      this.get('notificationCenter').confirm({
        title: config.CONFIRM_MESSAGES.generic,
        message: message,
        action: action
      });
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

      return fetch(`${config.DS.host}/${config.DS.namespace}/team_users`, {
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
          response.json().then((resp) => {
            if(this.get('currentModel').currentUser.get('id') == member.get('id')) {
              _this.transitionTo('app');
              _this.send('invalidateApplicationModel');
            }
            _this.controller.get('model').members.reload();
          });
        } else if(response.status === config.STATUS_CODES.forbidden) {
          // Can't delete last remaining admin
          _this.get('notificationCenter').error({
            title: config.ERROR_MESSAGES.generic,
            message: "It looks like you're currently the only admin on the team. In order to leave the team, you must assign another admin."
          });
        } else {
          _this.get('notificationCenter').error({
            title: config.ERROR_MESSAGES.generic,
            message: "We experienced an unexpected error. Please try again."
          });
        }
      });
    }
  }
});
