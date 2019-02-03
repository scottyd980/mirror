import DS from 'ember-data';
import attr from 'ember-data/attr';
import { belongsTo } from 'ember-data/relationships';

export default DS.Model.extend({
  message: attr('string'),
  feedback: belongsTo('feedback'),
  user: belongsTo('user')
});