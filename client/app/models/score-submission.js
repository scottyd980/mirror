import DS from 'ember-data';
import attr from 'ember-data/attr';
import { belongsTo } from 'ember-data/relationships';

export default DS.Model.extend({
  submitted: attr('boolean'),
  user: belongsTo('user'),
  retrospective: belongsTo('retrospective')
});
