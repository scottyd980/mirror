import Component from '@ember/component';
import { map, sort } from '@ember/object/computed';
import { computed } from '@ember/object';

export default Component.extend({
  tagName: "",
  sortedMembers: sort('members', 'memberSortDefinition'),
  memberSortDefinition: null,

  submitted_member_ids: computed('submitted.[]', function() {
    if(this.get('submitted')) {
      return this.get('submitted').map((submission) => {
        return submission.get('user.id');
      });
    }
    return [];
  }),

  init() {
    this._super(...arguments);
    this.set('memberSortDefinition', ['id:asc']);
  }
});
