import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { belongsTo, hasMany } from 'ember-data/relationships';

export default Model.extend({
  name: attr('string'),
  state: attr('number', {defaultValue: 0}),
  isAnonymous: attr('string'),
  game: attr('number'),
  team: belongsTo('team'),
  moderator: belongsTo('user'),
  participants: hasMany('user'),
  scores: hasMany('score'),
  feedbacks: hasMany('feedback'),
  feedbackSubmissions: hasMany('feedback_submission'),
  scoreSubmissions: hasMany('score_submission'),
  cancelled: attr('boolean'),
  updatedAt: attr('date')
});
