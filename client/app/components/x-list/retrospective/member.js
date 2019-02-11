import Component from '@ember/component';
import { sort } from '@ember/object/computed';

export default Component.extend({
  tagName: "",
  sortedMembers: sort('members', 'memberSortDefinition'),
  memberSortDefinition: null,

  init() {
    this._super(...arguments);
    this.set('memberSortDefinition', ['id:asc']);
  }
});
