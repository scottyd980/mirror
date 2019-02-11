import Component from '@ember/component';
import { map, sort } from '@ember/object/computed';

export default Component.extend({
  tagName: "",
  sortedMembers: sort('members', 'memberSortDefinition'),
  memberSortDefinition: null,

  submittedMembers: map('submitted', function (submission) {
    return submission.get('user.content');
  }),

  init() {
    this._super(...arguments);
    this.set('memberSortDefinition', ['id:asc']);
  }
});
