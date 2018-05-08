import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { belongsTo } from 'ember-data/relationships';

export default Model.extend({
  message: attr('string'),
  feedback: belongsTo('feedback'),
  user: belongsTo('user')
});
