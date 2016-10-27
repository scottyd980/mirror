import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { hasMany } from 'ember-data/relationships';
import { belongsTo } from 'ember-data/relationships';

export default Model.extend({
  name: attr('string'),
  state: attr('number'),
  isAnonymous: attr('string'),
  team: belongsTo('team'),
  moderator: belongsTo('user')
});
