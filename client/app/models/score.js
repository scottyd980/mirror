import DS from 'ember-data';
import attr from 'ember-data/attr';
import { belongsTo } from 'ember-data/relationships';

export default DS.Model.extend({
  score: attr('number'),
  user: belongsTo('user'),
  retrospective: belongsTo('retrospective'),
  uuid: attr('string')
});
