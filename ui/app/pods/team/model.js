import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { hasMany } from 'ember-data/relationships';
import { array } from 'model-fragments/attributes';

export default Model.extend({
  name: attr('string'),
  avatar: attr('string'),
  isAnonymous: attr('string'),
  admins: hasMany('user'),
  members: hasMany('user'),
  memberDelegates: array()
});
