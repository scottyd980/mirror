import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { belongsTo } from 'ember-data/relationships';

export default Model.extend({
  score: attr('number'),
  user: belongsTo('user'),
  retrospective: belongsTo('retrospective'),
  uuid: attr('string')
});
