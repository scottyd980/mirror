import DS from 'ember-data';
import attr from 'ember-data/attr';
import { hasMany, belongsTo } from 'ember-data/relationships';
import { array } from 'ember-data-model-fragments/attributes';

export default DS.Model.extend({
  name: attr('string'),
  avatar: attr('string'),
  isAnonymous: attr('string'),
  admins: hasMany('user'),
  members: hasMany('user'),
  retrospectives: hasMany('retrospective'),
  organization: belongsTo('organization'),
  memberDelegates: array()
});
