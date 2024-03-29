import DS from 'ember-data';
import attr from 'ember-data/attr';
import { belongsTo, hasMany } from 'ember-data/relationships';

export default DS.Model.extend({
  name: attr('string'),
  avatar: attr('string'),
  billing_status: attr('string'),
  billing_frequency: attr('string'),
  default_payment: belongsTo('card'),
  teams: hasMany('team'),
  admins: hasMany('user'),
  members: hasMany('user'),
  cards: hasMany('card', { inverse: 'organization' })
});