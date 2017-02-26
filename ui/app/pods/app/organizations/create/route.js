import Ember from 'ember';

export default Ember.Route.extend({
  session: Ember.inject.service('session'),
  model() {
    return this.store.createRecord('organization');
  },
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('errors', {});
    controller.set('orgMemberEmails', Ember.A());
    controller.set('newMemberIndex', 1);
  },
  actions: {
    addOrgMemberEmail(orgMember) {
      var _this = this;
      var idx = _this.controller.get('newMemberIndex');

      _this.controller.get('orgMemberEmails').pushObject({
        email: orgMember,
        index: idx
      });
      _this.controller.set('newMemberIndex', idx + 1);
      _this.controller.set('newOrgMemberEmail', '');
      $('#org-member-add').focus();
    },
    removeOrgMemberEmail(orgMember) {
      var _this = this;
      _this.controller.get('orgMemberEmails').removeObject(orgMember);
    },
    createOrganization() {
      var _this = this,
        delegates = [],
        membersToAdd = [];

      _this.get('currentModel').set('admin', _this.get('session').get('currentUser'));

      membersToAdd = _this.controller.get('orgMemberEmails');
      membersToAdd.push({
        email: _this.controller.get('newOrgMemberEmail')
      });

      delegates = membersToAdd.filter((item) => {
        return item.email != "" && item.email;
      }).map((item) => {
        return item.email;
      });

      //_this.get('currentModel').set('memberDelegates', delegates);

      _this.get('currentModel').save().then(() => {
        _this.controller.set('orgMemberEmails', Ember.A());
        _this.controller.set('newOrgMemberEmail', '');
        _this.send('invalidateApplicationModel');
      });
    }
  }
});
