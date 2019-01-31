import DS from 'ember-data';
import attr from 'ember-data/attr';
import { hasMany } from 'ember-data/relationships';

export default DS.Model.extend({
  username: attr('string'),
  email: attr('string'),
  password: attr('string'),
  passwordConfirmation: attr('string'),
  teamAdmin: hasMany('team', {inverse: 'admins'}),
  teams: hasMany('team', {inverse: 'members'}),
  organizationAdmin: hasMany('organization', {inverse: 'admins'}),
  organizations: hasMany('organization', {inverse: 'members'})
});
