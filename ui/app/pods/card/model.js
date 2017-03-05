import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { hasMany, belongsTo } from 'ember-data/relationships';

export default Model.extend({
  brand: attr('string'),
  last4: attr('string'),
  exp_month: attr('number'),
  exp_year: attr('number'),
  token_id: attr('string'),
  card_id: attr('string'),
  added_date: attr('date'),
  organization: belongsTo('organization')
});
