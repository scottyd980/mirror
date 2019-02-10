import DS from 'ember-data';
import attr from 'ember-data/attr';
import { belongsTo, hasMany } from 'ember-data/relationships';

export default DS.Model.extend({
  name: attr('string'),
  state: attr('number', {defaultValue: 0}),
  isAnonymous: attr('string'),
  game: attr('number'),
  team: belongsTo('team'),
  moderator: belongsTo('user'),
  participants: hasMany('user'),
  scores: hasMany('score'),
  active_feedback: belongsTo('feedback'),
  feedbacks: hasMany('feedback', {inverse: 'retrospective'}),
  feedbackSubmissions: hasMany('feedback_submission'),
  scoreSubmissions: hasMany('score_submission'),
  cancelled: attr('boolean'),
  updatedAt: attr('date')
});