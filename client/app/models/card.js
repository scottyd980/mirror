import DS from 'ember-data';
import attr from 'ember-data/attr';
import { belongsTo } from 'ember-data/relationships';

export default DS.Model.extend({
  brand: attr('string'),
  last4: attr('string'),
  exp_month: attr('number'),
  exp_year: attr('number'),
  token_id: attr('string'),
  card_id: attr('string'),
  zip_code: attr('string'),
  added_date: attr('date'),
  is_expired: attr('boolean'),
  organization: belongsTo('organization')
});
