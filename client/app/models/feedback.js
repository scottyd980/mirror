import DS from 'ember-data';
import attr from 'ember-data/attr';
import { belongsTo } from 'ember-data/relationships';

export default DS.Model.extend({
  category: attr('string'),
  message: attr('string'),
  state: attr('number', {defaultValue: 0}),
  user: belongsTo('user'),
  retrospective: belongsTo('retrospective'),
  action: belongsTo('action'),
  uuid: attr('string')
});
