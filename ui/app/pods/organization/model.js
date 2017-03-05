import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { hasMany } from 'ember-data/relationships';

export default Model.extend({
  name: attr('string'),
  avatar: attr('string'),
  default_payment: attr('string'),
  teams: hasMany('team'),
  admins: hasMany('user'),
  members: hasMany('user'),
  cards: hasMany('card')
});
