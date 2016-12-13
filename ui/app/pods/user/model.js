import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { hasMany } from 'ember-data/relationships';

export default Model.extend({
  username: attr('string'),
  email: attr('string'),
  password: attr('string'),
  passwordConfirmation: attr('string'),
  teamAdmin: hasMany('team', {inverse: 'admins'}),
  teams: hasMany('team', {inverse: 'members'})
});
