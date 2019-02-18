import Component from '@ember/component';
import { sort } from '@ember/object/computed';
import { computed } from '@ember/object';

export default Component.extend({
  tagName: "",
  sortedMembers: sort('members', 'memberSortDefinition'),
  memberSortDefinition: null,
  joined_member_ids: computed('joined_members.[]', function() {
    return this.get('joined_members').map((member) => {
      return member.id;
    });
  }),

  init() {
    this._super(...arguments);
    this.set('memberSortDefinition', ['id:asc']);
  }
});
