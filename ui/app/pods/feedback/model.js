import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { belongsTo, hasMany } from 'ember-data/relationships';

export default Model.extend({
  type: attr('string'),
  message: attr('string'),
  state: attr('number', {defaultValue: 0}),
  user: belongsTo('user'),
  retrospective: belongsTo('retrospective')
});
