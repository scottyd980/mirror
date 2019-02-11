import Controller from '@ember/controller';
import { inject as service } from '@ember/service';
import $ from 'jquery';
import { A } from '@ember/array';

export default Controller.extend({
  session: service(),
  errors: null,
  orgMemberEmails: null,
  newMemberIndex: null,
  currentlyLoading: false,
  unexpectedError: null,
  orgError: null,
  actions: {
    addOrgMemberEmail(orgMember) {
      var idx = this.get('newMemberIndex');

      this.get('orgMemberEmails').pushObject({
        email: orgMember,
        index: idx
      });
      this.set('newMemberIndex', idx + 1);
      this.set('newOrgMemberEmail', '');
      $('#org-member-add').focus();
    },
    removeOrgMemberEmail(orgMember) {
      this.get('orgMemberEmails').removeObject(orgMember);
    },
    createOrganization() {
      //let delegates = [],
      let membersToAdd = [];

      this.set('orgError', '');

      if(!this.get('model').get('name') || this.get('model').get('name').trim() === "") {
        this.set('orgError', 'Your organization needs a name!');
        return;
      }
      
      this.set('currentlyLoading', true);

      this.get('model').set('admin', this.get('session').get('currentUser'));

      membersToAdd = this.get('orgMemberEmails');
      membersToAdd.push({
        email: this.get('newOrgMemberEmail')
      });

      // delegates = membersToAdd.filter((item) => {
      //   return item.email !== "" && item.email;
      // }).map((item) => {
      //   return item.email;
      // });

      this.get('model').save().then(() => {
        this.set('orgMemberEmails', A());
        this.set('newOrgMemberEmail', '');
        this.set('currentlyLoading', false);
        this.send('invalidateApplicationModel');
        this.transitionToRoute('app.organizations.organization.dashboard', this.get('model'));
      }).catch(() => {
        this.set('currentlyLoading', false);
        this.set('unexpectedError', 'There was an unexpected error, please review the fields and try again.');
      });
    }
  }
});